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

	static func Abstraction(name: Name, _ body: ABTTerm) -> ABTTerm {
		return .In(body.freeVariables.subtract([ name ]), .Abstraction(name, body))
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

	func map<Other>(@noescape transform: Recur -> Other) -> AST<Other> {
		switch self {
		case let .Lambda(body):
			return .Lambda(transform(body))
		case let .Application(a, b):
			return .Application(transform(a), transform(b))
		}
	}
}

protocol MonoidType {
	static var mempty: Self { get }
	func mappend(other: Self) -> Self
}

extension Set: MonoidType {
	static var mempty: Set {
		return []
	}

	func mappend(other: Set) -> Set {
		return union(other)
	}
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
