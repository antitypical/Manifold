//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Scoping<Term>: CustomDebugStringConvertible {
	case Variable(Name)
	case Abstraction(Name, Term)
	case Identity(Expression<Term>)


	public var name: Name? {
		switch self {
		case let .Variable(name):
			return name
		case let .Abstraction(name, _):
			return name
		default:
			return nil
		}
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		switch self {
		case let .Variable(name):
			return ".Variable(\(String(reflecting: name)))"
		case let .Abstraction(name, scope):
			return ".Abstraction(\(String(reflecting: name)), \(scope))"
		case let .Identity(term):
			return ".Identity(\(term))"
		}
	}


	// MARK: Functor

	public func map<Other>(@noescape transform: Term throws -> Other) rethrows -> Scoping<Other> {
		switch self {
		case let .Variable(name):
			return .Variable(name)
		case let .Abstraction(name, term):
			return try .Abstraction(name, transform(term))
		case let .Identity(expression):
			return try .Identity(expression.map(transform))
		}
	}


	// MARK: Equatable

	public static func equal(termEqual: (Term, Term) -> Bool)(_ left: Scoping, _ right: Scoping) -> Bool {
		switch (left, right) {
		case let (.Variable(name1), .Variable(name2)):
			return name1 == name2
		case let (.Abstraction(name1, scope1), .Abstraction(name2, scope2)):
			return name1 == name2 && termEqual(scope1, scope2)
		case let (.Identity(expression1), .Identity(expression2)):
			return Expression.equal(termEqual)(expression1, expression2)
		default:
			return false
		}
	}
}


public func == <Term: Equatable> (left: Scoping<Term>, right: Scoping<Term>) -> Bool {
	return Scoping.equal(==)(left, right)
}
