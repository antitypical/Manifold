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


	public func definitions(symbol: Name, abstract: Term -> Term = id, abstractAndApply: (Term -> Term) -> Term -> Term = id) -> [DefinitionType] {
		switch self {
		case let .Argument(name, type, rest):
			return rest.definitions(symbol, abstract: { (name, type) => $0 } >>> abstract, abstractAndApply: { f in
				{ (name, type) => f(.Application($0, .Variable(name))) }
			} >>> abstractAndApply)
		case let .End(constructors):
			let recur = Term.Variable(symbol)
			let name = Name.Global("Motive")
			func value(recur: Term) -> Term {
				return (name, .Type) => constructors.map {
					$1.fold(recur, terminal: .Variable(name)) { ($0, $1) => $2 }
				}.reverse().reduce(.Variable(name), combine: flip(-->))
			}
			return [ (symbol, abstract(.Type), abstractAndApply(value)(recur)) ] + constructors.map {
				(.Global($0), abstractAndApply(type($1))(recur), abstractAndApply(self.value($0, telescope: $1, constructors: constructors))(recur))
			}
		}
	}

	public func type(telescope: Telescope)(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(name, rest):
			return (name, recur) => type(rest)(recur)
		case let .Argument(name, type, rest):
			return (name, type) => self.type(rest)(recur)
		case .End:
			return recur
		}
	}

	public func value(symbol: String, telescope: Telescope, constructors: [(String, Telescope)], parameters: [Term] = [])(_ recur: Term) -> Term {
		switch telescope {
		case let .Recursive(name, rest):
			return (name, recur) => value(symbol, telescope: rest, constructors: constructors, parameters: parameters + [ .Variable(name) ])(recur)
		case let .Argument(name, type, rest):
			return (name, type) => value(symbol, telescope: rest, constructors: constructors, parameters: parameters + [ .Variable(name) ])(recur)
		case .End:
			let name = Name.Global("Motive")
			let constructors = constructors.map {
				($0, $1.fold(recur, terminal: .Variable(name)) { ($0, $1) => $2 })
			}
			return (name, .Type) => constructors.reverse().reduce(id, combine: { into, each in
				each.0 == symbol
					? { _ in (Name.Global("if" + symbol), each.1) => into(parameters.reduce(.Variable(Name.Global("if" + symbol)), combine: { $0[$1] })) }
					: into >>> { each.1 --> $0 }
			})(.Variable(name))
		}
	}
}


import Prelude
