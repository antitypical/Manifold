//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Datatype: DictionaryLiteralConvertible {
	indirect case Argument(Name, Term, Datatype)
	case End([(String, Telescope)])


	public init(_ name: Name, _ type: Term, _ rest: Datatype) {
		self = .Argument(name, type, rest)
	}

	public init(_ name1: Name, _ type1: Term, _ name2: Name, _ type2: Term, _ rest: Datatype) {
		self = .Argument(name1, type1, .Argument(name2, type2, rest))
	}


	public init(dictionaryLiteral: (String, Telescope)...) {
		self = .End(dictionaryLiteral)
	}


	public func definitions(symbol: Name, index: Int = 0, abstract: Term -> Term = id, abstractAndApply: (Term -> Term) -> Term -> Term = id) -> [DefinitionType] {
		switch self {
		case let .Argument(name, type, rest):
			return rest.definitions(symbol, index: index + 1, abstract: { (name, type) => $0 } >>> abstract, abstractAndApply: { f in
				{ (name, type) => f(.Application($0, .Variable(name))) }
			} >>> abstractAndApply)
		case let .End(constructors):
			let recur = Term.Variable(symbol)
			let name = Name.Local(index)
			func value(recur: Term) -> Term {
				return (name, .Type) => constructors.map {
					$1.fold(recur, terminal: .Variable(.Local(index)), index: index + 1) { ($0, $1) => $2 }
				}.reverse().reduce(.Variable(name), combine: flip(-->))
			}
			return [ (symbol, abstract(.Type), abstractAndApply(value)(recur)) ] + constructors.map {
				(.Global($0), abstractAndApply(type($1, index: index))(recur), abstractAndApply(self.value($0, telescope: $1, constructors: constructors, index: index))(recur))
			}
		}
	}

	public func type(telescope: Telescope, index: Int)(_ recur: Term) -> Term {
		let name = Name.Local(index)
		switch telescope {
		case let .Recursive(rest):
			return (name, recur) => type(rest, index: index + 1)(recur)
		case let .Argument(type, rest):
			return (name, type) => self.type(rest, index: index + 1)(recur)
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], index: Int, parameters: [Term] = [])(_ recur: Term) -> Term {
		let name = Name.Local(index)
		switch telescope {
		case let .Recursive(rest):
			return (name, recur) => value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case let .Argument(type, rest):
			return (name, type) => value(symbol, telescope: rest, constructors: constructors, index: index + 1, parameters: parameters + [ .Variable(name) ])(recur)
		case .End:
			let constructors = constructors.map {
				($0, $1.fold(recur, terminal: .Variable(name), index: index + 1) { ($0, $1) => $2 })
			}
			return (name, .Type) => constructors.reverse().reduce((id, index + 1), combine: { into, each in
				(each.0 == symbol
					? { _ in (Name.Local(into.1), each.1) => into.0(parameters.reduce(.Variable(Name.Local(into.1)), combine: { $0[$1] })) }
					: into.0 >>> { each.1 --> $0 }, into.1 + 1)
			}).0(.Variable(name))
		}
	}
}


import Prelude
