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


	public func definitions(recur: Term, index: Int = 0, abstract: (Term -> Term) -> Term -> Term = id) -> [(Name, Term, Term)] {
		switch self {
		case let .Argument(type, rest):
			let name = Name.Local(index)
			return rest.definitions(recur, index: index + 1, abstract: { f in
				{ recur in
					(name, type) => f(.Application(recur, .Variable(name)))
				}
			} >>> abstract)
		case let .End(constructors):
			return constructors.map {
				(.Global($0), abstract(self.type($1, index: index))(recur), abstract(self.value($0, telescope: $1, constructors: constructors))(recur))
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

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], index: Int = 0, parameters: [Term] = [])(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(rest):
			let name = Name.Local(index)
			return (name, recur) => self.value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case let .Argument(type, rest):
			let name = Name.Local(index)
			return (name, type) => self.value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case .End:
			return .Type => { motive in
				constructors.map {
					($0, $1.fold(recur, terminal: motive, index: index, combine: -->))
				}.reverse().reduce(id, combine: { into, each in
					each.0 == symbol
						? { _ in each.1 => { into(parameters.reduce($0, combine: { $0[$1] })) } }
						: into >>> { each.1 --> $0 }
				})(motive)
			}
		}
	}

	public func withTypeParameters(recur: Term, index: Int = 0, continuation: (Term, Int, [(String, Telescope)]) -> Term) -> Term {
		switch self {
		case let .Argument(type, rest):
			let name = Name.Local(index)
			return (name, type) => rest.withTypeParameters(.Application(recur, .Variable(name)), index: index + 1, continuation: continuation)
		case let .End(constructors):
			return continuation(recur, index, constructors)
		}
	}


	public func type() -> Term {
		return withTypeParameters(.Type, continuation: const(.Type))
	}

	public func value(recur: Term) -> Term {
		return withTypeParameters(recur) { recur, index, constructors in
			(Name.Local(index), .Type) => constructors.map {
				$1.fold(recur, terminal: .Variable(.Local(index)), index: index + 1, combine: -->)
			}.reverse().reduce(.Variable(Name.Local(index)), combine: flip(-->))
		}
	}
}


import Prelude
