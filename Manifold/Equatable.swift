//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: Checkable

public func == <Recur: Equatable> (left: Checkable<Recur>, right: Checkable<Recur>) -> Bool {
	switch (left, right) {
	case (.UnitTerm, .UnitTerm), (.UnitType, .UnitType):
		return true
	case let (.Type(i), .Type(j)):
		return i == j
	case let (.Bound(m), .Bound(n)):
		return m == n
	case let (.Free(m), .Free(n)):
		return m == n
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1 == u1 && t2 == u2
	case let (.Pi(t, a), .Pi(u, b)):
		return t == u && a == b
	case let (.Projection(p, f), .Projection(q, g)):
		return p == q && f == g
	case let (.Sigma(t, a), .Sigma(u, b)):
		return t == u && a == b
	default:
		return false
	}
}


// MARK: Error

public func == (left: Error, right: Error) -> Bool {
	return lazy(zip(left.errors, right.errors))
		.map(==).reduce(true) { $0 && $1 }
}


// MARK: Name

public func == (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Global(x), .Global(y)):
		return x == y
	case let (.Local(x), .Local(y)):
		return x == y
	case let (.Quote(x), .Quote(y)):
		return x == y
	default:
		return false
	}
}


// MARK: Term

public func == (left: Term, right: Term) -> Bool {
	return left.expression == right.expression
}


// MARK: Value

public func == (left: Value, right: Value) -> Bool {
	return left.quote == right.quote
}
