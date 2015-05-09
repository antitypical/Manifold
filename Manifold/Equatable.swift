//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: DTerm

public func == (left: DTerm, right: DTerm) -> Bool {
	return left.expression == right.expression
}


// MARK: DTerm.Sort

public func == (left: DTerm.Sort, right: DTerm.Sort) -> Bool {
	switch (left, right) {
	case (.Term, .Term), (.Type, .Type), (.Kind, .Kind):
		return true
	default:
		return false
	}
}


// MARK: DExpression

public func == <Recur: Equatable> (left: DExpression<Recur>, right: DExpression<Recur>) -> Bool {
	switch (left, right) {
	case (.Kind, .Kind), (.Type, .Type):
		return true
	case let (.Variable(m), .Variable(n)):
		return m == n
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1.value == u1.value && t2.value == u2.value
	case let (.Pi(i, t, a), .Pi(j, u, b)):
		return i == j && t.value == u.value && a.value == b.value
	case let (.Sigma(i, t, a), .Sigma(j, u, b)):
		return i == j && t.value == u.value && a.value == b.value
	default:
		return false
	}
}


// MARK: Error

public func == (left: Error, right: Error) -> Bool {
	return reduce(lazy(zip(left.errors, right.errors))
		.map(==), true) { $0 && $1 }
}
