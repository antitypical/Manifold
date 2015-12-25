//  Copyright © 2015 Rob Rix. All rights reserved.

indirect enum ABTTerm {
	case In(Set<Name>, Scoping<AST<ABTTerm>, ABTTerm>)

	static func Variable(name: Name) -> ABTTerm {
		return .In([ name ], .Variable(name))
	}

	static func Abstraction(name: Name, _ body: ABTTerm) -> ABTTerm {
		return .In(body.freeVariables.subtract([ name ]), .Abstraction(name, body))
	}

	static func Constructor(body: AST<ABTTerm>) -> ABTTerm {
		return .In(body.foldMap { $0.freeVariables }, .Identity(body))
	}

	var freeVariables: Set<Name> {
		guard case let .In(variables, _) = self else { return [] }
		return variables
	}

	var out: Scoping<AST<ABTTerm>, ABTTerm> {
		switch self {
		case let .In(_, out):
			return out
		}
	}

	func rename(old: Name, _ new: Name) -> ABTTerm {
		switch out {
		case let .Variable(name):
			return name == old
				? .Variable(new)
				: self
		case let .Abstraction(name, body):
			return name == old
				? self
				: .Abstraction(name, body.rename(old, new))
		case let .Identity(syntax):
			return .Constructor(syntax.map { $0.rename(old, new) })
		}
	}

	func substitute(variable: Name, with: ABTTerm) -> ABTTerm {
		switch out {
		case let .Variable(name) where name == variable:
			return with
		case .Variable:
			return self
		case let .Abstraction(name, scope):
			let newName = name.fresh(freeVariables.union(with.freeVariables))
			return .Abstraction(newName, name != newName
				? scope.rename(name, newName).substitute(variable, with: with)
				: scope.substitute(variable, with: with))
		case let .Identity(syntax):
			return .Constructor(syntax.map { $0.substitute(variable, with: with) })
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

	func foldMap<Result: MonoidType>(@noescape transform: Recur -> Result) -> Result {
		switch self {
		case let .Lambda(body):
			return transform(body)
		case let .Application(a, b):
			return transform(a).mappend(transform(b))
		}
	}
}
