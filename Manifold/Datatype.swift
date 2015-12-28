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


	public func definitions(symbol: Name, index: Int = 0, abstract: Term -> Term = id, abstractAndApply: (Term -> Term) -> Term -> Term = id) -> [DefinitionType] {
		switch self {
		case let .Argument(type, rest):
			let name = Name.Local(index)
			return rest.definitions(symbol, index: index + 1, abstract: { type --> $0 }, abstractAndApply: { f in
				{ recur in
					(name, type) => f(.Application(recur, .Variable(name)))
				}
			} >>> abstractAndApply)
		case let .End(constructors):
			let recur = Term.Variable(symbol)
			return [ (symbol, abstract(.Type), value(symbol)) ] + constructors.map {
				(.Global($0), abstractAndApply(self.type($1))(recur), abstractAndApply(self.value($0, telescope: $1, constructors: constructors, index: index))(recur))
			}
		}
	}

	public func type(telescope: Telescope)(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(rest):
			return recur --> type(rest)(recur)
		case let .Argument(type, rest):
			return type --> self.type(rest)(recur)
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], index: Int, parameters: [Term] = [])(_ recur: Term) -> Term {
		let name = Name.Local(index)
		switch telescope {
		case let .Recursive(rest):
			return (name, recur) => self.value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case let .Argument(type, rest):
			return (name, type) => self.value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case .End:
			let constructors = constructors.map {
				($0, $1.fold(recur, terminal: .Variable(name), index: index + 1, combine: -->))
			}
			return (name, .Type) => constructors.reverse().reduce((id, index + 1), combine: { into, each in
				(each.0 == symbol
					? { _ in (Name.Local(into.1), each.1) => into.0(parameters.reduce(.Variable(Name.Local(into.1)), combine: { $0[$1] })) }
					: into.0 >>> { each.1 --> $0 }, into.1 + 1)
			}).0(.Variable(name))
		}
	}


	public func type() -> Term {
		switch self {
		case let .Argument(type, rest):
			return type --> rest.type()
		case .End:
			return .Type
		}
	}

	public func value(symbol: Name) -> Term {
		func value(datatype: Datatype, recur: Term, index: Int) -> Term {
			let name = Name.Local(index)
			switch datatype {
			case let .Argument(type, rest):
				return (name, type) => value(rest, recur: .Application(recur, .Variable(name)), index: index + 1)
			case let .End(constructors):
				return (name, .Type) => constructors.map {
					$1.fold(recur, terminal: .Variable(.Local(index)), index: index + 1, combine: -->)
				}.reverse().reduce(.Variable(name), combine: flip(-->))
			}
		}
		return value(self, recur: .Variable(symbol), index: 0)
	}
}


import Prelude
