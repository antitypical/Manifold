//  Copyright © 2015 Rob Rix. All rights reserved.

// MARK: Expression

public func == <Recur: Equatable> (left: Expression<Recur>, right: Expression<Recur>) -> Bool {
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
	case let (.Product(t, a), .Product(u, b)):
		return t == u && a == b
	case let (.Boolean(a), .Boolean(b)):
		return a == b
	case let (.If(a1, b1, c1), .If(a2, b2, c2)):
		return a1 == a2 && b1 == b2 && c1 == c2
	case let (.Annotation(term1, type1), .Annotation(term2, type2)):
		return term1 == term2 && type1 == type2
	case let (.Axiom(_, type1), .Axiom(_, type2)):
		return type1 == type2
	default:
		return false
	}
}

extension Expression where Recur: FixpointType {
	public static func alphaEquivalent(left: Expression, _ right: Expression, _ environment: Environment) -> Bool {
		let recur: (Expression, Expression) -> Bool = {
			alphaEquivalent($0, $1, environment)
		}
		switch (left.weakHeadNormalForm(environment).destructured, right.weakHeadNormalForm(environment).destructured) {
		case (.Type, .Type), (.Unit, .Unit), (.UnitType, .UnitType), (.BooleanType, .BooleanType):
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

		case let (.Boolean(a), .Boolean(b)):
			return a == b

		case let (.If(a1, a2, a3), .If(b1, b2, b3)):
			return recur(a1, b1) && recur(a2, b2) && recur(a3, b3)

		case let (.Annotation(a1, a2), .Annotation(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Axiom(_, a), .Axiom(_, b)):
			return recur(a, b)

		default:
			return false
		}
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


// MARK: FixpointType

public func == <Fix: FixpointType> (left: Fix, right: Fix) -> Bool {
	return left.out == right.out
}
