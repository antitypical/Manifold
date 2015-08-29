//  Copyright © 2015 Rob Rix. All rights reserved.

// MARK: Expression

public func == <Recur: Equatable> (left: Expression<Recur>, right: Expression<Recur>) -> Bool {
	switch (left, right) {
	case (.Unit, .Unit), (.UnitType, .UnitType):
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
	case let (.Product(t, a), .Product(u, b)):
		return t == u && a == b
	case let (.Annotation(term1, type1), .Annotation(term2, type2)):
		return term1 == term2 && type1 == type2
	case let (.Enumeration(m), .Enumeration(n)):
		return m == n
	case let (.Tag(x1, x2), .Tag(y1, y2)):
		return x1 == y1 && x2 == y2
	case let (.Switch(t, l), .Switch(u, m)):
		return t == u && l == m
	default:
		return false
	}
}

extension Expression where Recur: TermType {
	public static func alphaEquivalent(left: Expression, _ right: Expression, _ environment: Environment, var _ visited: Set<Name> = []) -> Bool {
		let recur: (Expression, Expression) -> Bool = {
			alphaEquivalent($0, $1, environment, visited)
		}

		let normalize: (Expression, Set<Name>) -> (Expression, Set<Name>) = { (expression, var visited) in
			(expression.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited), visited)
		}

		let (left, lnames) = normalize(left, visited)
		let (right, rnames) = normalize(right, visited)
		visited.unionInPlace(lnames)
		visited.unionInPlace(rnames)

		switch (left.destructured, right.destructured) {
		case (.Type, .Type), (.Unit, .Unit), (.UnitType, .UnitType):
			return true

		case let (.Variable(a), .Variable(b)):
			return a == b

		case let (.Application(a1, a2), .Application(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Lambda(_, a1, a2), .Lambda(_, b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Projection(a1, a2), .Projection(b1, b2)):
			return recur(a1, b1) && a2 == b2

		case let (.Product(a1, a2), .Product(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Annotation(a1, a2), .Annotation(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		default:
			return false
		}
	}
}


// MARK: Error

public func == (left: Error, right: Error) -> Bool {
	return zip(left.errors, right.errors)
		.lazy
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


// MARK: TermType

public func == <Fix: TermType> (left: Fix, right: Fix) -> Bool {
	return left.out == right.out
}


// MARK: Tag

public func == (left: Tag, right: Tag) -> Bool {
	switch (left, right) {
	case let (.Here(x, xs), .Here(y, ys)):
		return x == y && xs == ys

	case let (.There(x, xs), .There(y, ys)):
		return x == y && xs == ys

	default:
		return false
	}
}
