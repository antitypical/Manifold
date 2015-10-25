//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Datatype<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Argument(Recur, Recur -> Datatype)
	case End([(String, Telescope<Recur>)])


	public init(_ type: Recur, _ constructor: Recur -> Datatype<Recur>) {
		self = .Argument(type, constructor)
	}

	public init(_ type1: Recur, _ type2: Recur, _ constructor: (Recur, Recur) -> Datatype<Recur>) {
		self = .Argument(type1, { a in Datatype.Argument(type2) { b in constructor(a, b) } })
	}


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(dictionaryLiteral)
	}


	public func definitions(recur: Recur, abstract: (Recur -> Recur) -> Recur -> Recur = { f in { f($0) } }) -> [Declaration<Recur>.DefinitionType] {
		switch self {
		case let .Argument(type, continuation):
			var parameter = Recur.Variable(.Local(-1))
			return continuation(Recur { parameter.out }).definitions(recur, abstract: { f in
				{ recur in
					Recur.lambda(type, {
						// We compute the continuation of the type constructor with respect to a parameter, but we need it to match up with the variable bound by this lambda at runtime. Since `TermType.self.lambda()` already implements the desired [circular programming](http://chris.eidhof.nl/posts/repmin-in-swift.html) behaviour, we can simply copy it out at this point and get the desired lazily-normalizing circular behaviour for the type constructor itself, instantiated correctly for each data constructor—even though they may have different numbers of parameters, and thus bind the type constructor’s parameter at a different variable.
						parameter = $0
						return f(.Application(recur, $0))
					})
				}
			} >>> abstract)
		case let .End(constructors):
			return constructors.map {
				// Since at this point the type and value both close over the same parameter despite its inevitable use at two different indices, we copy them recursively using `Recur(term:)` to ensure that they’re finished with the shared state by the time they’re returned to the caller.
				($0, Recur(term: abstract(self.type($1))(recur)), Recur(term: abstract(self.value($0, telescope: $1, constructors: constructors))(recur)))
			}
		}
	}

	public func type(telescope: Telescope<Recur>)(_ recur: Recur) -> Recur {
		switch telescope {
		case let .Recursive(rest):
			return recur --> type(rest)(recur)
		case let .Argument(type, continuation):
			return type => { self.type(continuation($0))(recur) }
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope<Recur>, constructors: [(String, Telescope<Recur>)], parameters: [Recur] = [])(_ recur: Recur) -> Recur {
		switch telescope {
		case let .Recursive(rest):
			return recur => { self.value(symbol, telescope: rest, constructors: constructors, parameters: parameters + [ $0 ])(recur) }
		case let .Argument(type, continuation):
			return type => { self.value(symbol, telescope: continuation($0), constructors: constructors, parameters: parameters + [ $0 ])(recur) }
		case .End:
			return .Type => { motive in
				constructors.map {
					($0, $1.fold(recur, terminal: motive, combine: -->))
				}.reverse().reduce(id, combine: { into, each in
					each.0 == symbol
						? { _ in each.1 => { into(parameters.reduce($0, combine: { $0[$1] })) } }
						: into >>> { each.1 --> $0 }
				})(motive)
			}
		}
	}

	public func withTypeParameters(continuation: [(String, Telescope<Recur>)] -> Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return type => { rest($0).withTypeParameters(continuation) }
		case let .End(constructors):
			return continuation(constructors)
		}
	}

	public func withTypeParameters(recur: Recur, continuation: (Recur, [(String, Telescope<Recur>)]) -> Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return type => { rest($0).withTypeParameters(.Application(recur, $0), continuation: continuation) }
		case let .End(constructors):
			return continuation(recur, constructors)
		}
	}


	public func type() -> Recur {
		return withTypeParameters(const(.Type))
	}

	public func value(recur: Recur) -> Recur {
		return withTypeParameters(recur) { recur, constructors in
			.Type => { motive in
				constructors.map {
					$1.fold(recur, terminal: motive, combine: -->)
				}.reverse().reduce(motive, combine: flip(-->))
			}
		}
	}
}


import Prelude
