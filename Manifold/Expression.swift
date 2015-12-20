//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Expression<Recur> {
	case Type(Int)
	case Variable(Name)
	case Application(Recur, Recur)
	case Lambda(Int, Recur, Recur)
	case Embedded(Any, (Any, Any) -> Bool, Recur)
	case Implicit


	// MARK: Functor

	public func map<T>(@noescape transform: Recur throws -> T) rethrows -> Expression<T> {
		switch self {
		case let .Type(i):
			return .Type(i)
		case let .Variable(n):
			return .Variable(n)
		case let .Application(a, b):
			return try .Application(transform(a), transform(b))
		case let .Lambda(i, a, b):
			return try .Lambda(i, transform(a), transform(b))
		case let .Embedded(a, eq, b):
			return try .Embedded(a, eq, transform(b))
		case .Implicit:
			return .Implicit
		}
	}


	// MARK: Equality

	public static func equal(equal: (Recur, Recur) -> Bool)(_ left: Expression, _ right: Expression) -> Bool {
		switch (left, right) {
		case let (.Type(i), .Type(j)):
			return i == j
		case let (.Variable(m), .Variable(n)):
			return m == n
		case let (.Application(t1, t2), .Application(u1, u2)):
			return equal(t1, u1) && equal(t2, u2)
		case let (.Lambda(i, t, a), .Lambda(j, u, b)):
			return i == j && equal(t, u) && equal(a, b)
		case let (.Embedded(a, eq, t1), .Embedded(b, _, t2)) where a.dynamicType == b.dynamicType:
			return eq(a, b) && equal(t1, t2)
		case (.Implicit, .Implicit):
			return true
		default:
			return false
		}
	}
}


public func == <Recur: Equatable> (left: Expression<Recur>, right: Expression<Recur>) -> Bool {
	return Expression.equal(==)(left, right)
}


import Prelude
