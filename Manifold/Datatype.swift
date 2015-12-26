//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Datatype: DictionaryLiteralConvertible {
	indirect case Argument(Term, Term -> Datatype)
	case End([(String, Telescope)])


	public init(_ type: Term, _ constructor: Term -> Datatype) {
		self = .Argument(type, constructor)
	}

	public init(_ type1: Term, _ type2: Term, _ constructor: (Term, Term) -> Datatype) {
		self = .Argument(type1, { a in Datatype.Argument(type2) { b in constructor(a, b) } })
	}


	public init(dictionaryLiteral: (String, Telescope)...) {
		self = .End(dictionaryLiteral)
	}


	public func definitions(recur: Term, abstract: (Term -> Term) -> Term -> Term = { f in { f($0) } }) -> [(Name, Term, Term)] {
		switch self {
		case let .Argument(type, continuation):
			return continuation(-1).definitions(recur, abstract: { f in
				{ recur in
					type => {
						// We compute the continuation of the type constructor with respect to a parameter, but we need it to match up with the variable bound by this lambda at runtime. Since `=>` already implements the desired [circular programming](http://chris.eidhof.nl/posts/repmin-in-swift.html) behaviour, we can simply copy it out at this point and get the desired lazily-normalizing circular behaviour for the type constructor itself, instantiated correctly for each data constructor—even though they may have different numbers of parameters, and thus bind the type constructor’s parameter at a different variable.
						return f(.Application(recur, $0))
					}
				}
			} >>> abstract)
		case let .End(constructors):
			return constructors.map {
				(.Global($0), abstract(self.type($1))(recur), abstract(self.value($0, telescope: $1, constructors: constructors))(recur))
			}
		}
	}

	public func type(telescope: Telescope)(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(rest):
			return recur --> type(rest)(recur)
		case let .Argument(type, continuation):
			return type => { self.type(continuation($0))(recur) }
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], parameters: [Term] = [])(_ recur: Term) -> Term {
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

	public func withTypeParameters(recur: Term, continuation: (Term, [(String, Telescope)]) -> Term) -> Term {
		switch self {
		case let .Argument(type, rest):
			return type => { rest($0).withTypeParameters(.Application(recur, $0), continuation: continuation) }
		case let .End(constructors):
			return continuation(recur, constructors)
		}
	}


	public func type() -> Term {
		return withTypeParameters(.Type, continuation: const(.Type))
	}

	public func value(recur: Term) -> Term {
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
