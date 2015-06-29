//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: Checkable

public func == <Recur: Equatable> (left: Checkable<Recur>, right: Checkable<Recur>) -> Bool {
	switch (left, right) {
	case let (.Inferable(a), .Inferable(b)):
		return a == b
	}
}


// MARK: Inferable

public func == <Recur: Equatable> (left: Inferable<Recur>, right: Inferable<Recur>) -> Bool {
	switch (left, right) {
	case (.Unit, .Unit), (.UnitType, .UnitType), (.BooleanType, .BooleanType):
		return true
	case let (.Type(i), .Type(j)):
		return i == j
	case let (.Variable(m), .Variable(n)):
		return m == n
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1 == u1 && t2 == u2
	case let (.Lambda(i, t, a), .Lambda(j, u, b)):
		return i == j && t == u && a == b
	case let (.Projection(p, f), .Projection(q, g)):
		return p == q && f == g
	case let (.Sigma(i, t, a), .Sigma(j, u, b)):
		return i == j && t == u && a == b
	case let (.Boolean(a), .Boolean(b)):
		return a == b
	case let (.If(a1, b1, c1), .If(a2, b2, c2)):
		return a1 == a2 && b1 == b2 && c1 == c2
	case let (.Annotation(term1, type1), .Annotation(term2, type2)):
		return term1 == term2 && type1 == type2
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
	default:
		return false
	}
}


// MARK: Term

public func == (left: Term, right: Term) -> Bool {
	return left.expression == right.expression
}
