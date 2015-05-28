//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: Checkable

public func == <Recur: Equatable> (left: Checkable<Recur>, right: Checkable<Recur>) -> Bool {
	switch (left, right) {
	case let (.Type(i), .Type(j)):
		return i == j
	case let (.Bound(m), .Bound(n)):
		return m == n
	case let (.Free(m), _):
		// Workaround for rdar://20969594
		switch right {
		case let .Free(n):
			return m == n
		default:
			break
		}
		return false
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1.value == u1.value && t2.value == u2.value
	case let (.Pi(t, a), .Pi(u, b)):
		return t.value == u.value && a.value == b.value
	case let (.Sigma(t, a), .Sigma(u, b)):
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
