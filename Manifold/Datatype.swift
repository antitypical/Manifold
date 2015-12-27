//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Datatype: DictionaryLiteralConvertible {
	indirect case Argument(Term, Datatype)
	case End([(String, Telescope)])


	public init(_ type: Term, _ rest: Datatype) {
		self = .Argument(type, rest)
	}

	public init(_ type1: Term, _ type2: Term, _ rest: Datatype) {
		self = .Argument(type1, .Argument(type2, rest))
	}


	public init(dictionaryLiteral: (String, Telescope)...) {
		self = .End(dictionaryLiteral)
	}


	public func definitions(recur: Term, abstract: (Term -> Term) -> Term -> Term = id) -> [(Name, Term, Term)] {
		switch self {
		case let .Argument(type, rest):
			return rest.definitions(recur, abstract: { f in
				{ recur in
					type => {
						f(.Application(recur, $0))
					}
				}
			} >>> abstract)
		case let .End(constructors):
			return constructors.map {
				(.Global($0), abstract(self.type($1))(recur), abstract(self.value($0, telescope: $1, constructors: constructors))(recur))
			}
		}
	}

	public func type(telescope: Telescope, index: Int = 0)(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(rest):
			return recur --> type(rest, index: index + 1)(recur)
		case let .Argument(type, rest):
			return (Name.Local(index), type) => self.type(rest, index: index + 1)(recur)
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], parameters: [Term] = [])(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(rest):
			return recur => { self.value(symbol, telescope: rest, constructors: constructors, parameters: parameters + [ $0 ])(recur) }
		case let .Argument(type, rest):
			let name = Name.Local(parameters.count)
			return (name, type) => self.value(symbol, telescope: rest, constructors: constructors, parameters: parameters + [ .Variable(name) ])(recur)
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
			return type => { rest.withTypeParameters(.Application(recur, $0), continuation: continuation) }
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
