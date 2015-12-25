//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public var freeVariables: Set<Name> {
		switch self {
		case let .In(freeVariables, _):
			return freeVariables
		}
	}

	public func rename(old: Name, _ new: Name) -> Term {
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
			return .Identity(syntax.map { $0.rename(old, new) })
		}
	}

	public func substitute(variable: Name, with: Term) -> Term {
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
			return .Identity(syntax.map { $0.substitute(variable, with: with) })
		}
	}
}
