//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Argument(Recur, Recur -> TypeConstructor)
	case End(Datatype<Recur>)


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(Datatype(constructors: dictionaryLiteral))
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
		case let .End(datatype):
			return datatype.definitions().map {
				// Since at this point the type and value both close over the same parameter despite its inevitable use at two different indices, we copy them recursively using `Recur(term:)` to ensure that they’re finished with the shared state by the time they’re returned to the caller.
				($0, Recur(term: abstract($1)(recur)), Recur(term: abstract($2)(recur)))
			}
		}
	}

	public func withTypeParameters(continuation: Datatype<Recur> -> Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return type => { rest($0).withTypeParameters(continuation) }
		case let .End(datatype):
			return continuation(datatype)
		}
	}

	public func withTypeParameters(recur: Recur, continuation: (Recur, Datatype<Recur>) -> Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return type => { rest($0).withTypeParameters(.Application(recur, $0), continuation: continuation) }
		case let .End(datatype):
			return continuation(recur, datatype)
		}
	}

	public func withTelescopes(datatype: Datatype<Recur>, transform: Telescope<Recur> -> Recur) -> [Recur] {
		func withTelescopes(collected: [Recur], datatype: Datatype<Recur>) -> [Recur] {
			switch datatype {
			case let .Constructor(_, telescope, rest):
				return withTelescopes(collected + [ transform(telescope) ], datatype: rest)
			case .End:
				return collected
			}
		}
		return withTelescopes([], datatype: datatype)
	}


	public func type() -> Recur {
		return withTypeParameters(const(.Type))
	}

	func type(telescope: Telescope<Recur>, _ recur: Recur, _ motive: Recur) -> Recur {
		switch telescope {
		case let .Recursive(rest):
			return recur --> type(rest, recur, motive)
		case let .Argument(type, continuation):
			return type => { self.type(continuation($0), recur, motive) }
		case .End:
			return motive
		}
	}

	func type(datatype: Datatype<Recur>, _ recur: Recur, _ motive: Recur) -> Recur {
		switch datatype {
		case let .Constructor(_, telescope, rest):
			return type(telescope, recur, motive) --> type(rest, recur, motive)
		case .End:
			return motive
		}
	}


	public func type(recur: Recur) -> Recur {
		switch self {
		case let .Argument(type, continuation):
			return Recur.lambda(type) {
				continuation($0).type(.Application(recur, $0))
			}
		case .End:
			return .Type
		}
	}


	public func value(recur: Recur) -> Recur {
		return withTypeParameters(recur) { recur, datatype in
			.Type => { motive in
				self.withTelescopes(datatype) {
					self.type($0, recur, motive)
				}.reverse().reduce(motive, combine: -->)
			}
		}
	}
}


import Prelude
