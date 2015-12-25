//  Copyright © 2015 Rob Rix. All rights reserved.

enum ABT<Applied, Recur> {
	case Variable(Name)
	case Abstraction(Name, Recur)
	case Constructor(Applied)
}

indirect enum ABTTerm {
	case In(Set<Name>, ABT<AST<ABTTerm>, ABTTerm>)

	static func Variable(name: Name) -> ABTTerm {
		return .In([ name ], .Variable(name))
	}

	var freeVariables: Set<Name> {
		guard case let .In(variables, _) = self else { return [] }
		return variables
	}

	var out: ABT<AST<ABTTerm>, ABTTerm> {
		switch self {
		case let .In(_, out):
			return out
		}
	}
}

enum AST<Recur> {
	case Lambda(Recur)
	case Application(Recur, Recur)
}

extension Name {
	func fresh(isUsed: Name -> Bool) -> Name {
		guard isUsed(self) else { return self }
		switch self {
		case let .Local(i):
			return Name.Local(i + 1).fresh(isUsed)
		case let .Global(string):
			return Name.Global(string + "ʹ").fresh(isUsed)
		}
	}
}
