//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: Constraint

public func == (left: Constraint, right: Constraint) -> Bool {
	switch (left, right) {
	case let (.Equality(x1, y1), .Equality(x2, y2)):
		return x1 == x2 && y1 == y2

	default:
		return false
	}
}


// MARK: DTerm

public func == (left: DTerm, right: DTerm) -> Bool {
	return left.expression == right.expression
}


// MARK: DExpression

public func == <Recur: Equatable> (left: DExpression<Recur>, right: DExpression<Recur>) -> Bool {
	switch (left, right) {
	case (.Kind, .Kind), (.Type, .Type):
		return true
	case let (.Variable(m, t), .Variable(n, u)):
		return m == n && t.value == u.value
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1.value == u1.value && t2.value == u2.value
	case let (.Abstraction(t, a), .Abstraction(u, b)):
		return t.value == u.value && a.value == b.value
	default:
		return false
	}
}


// MARK: Error

public func == (left: Error, right: Error) -> Bool {
	return reduce(lazy(zip(left.errors, right.errors))
		.map(==), true) { $0 && $1 }
}
