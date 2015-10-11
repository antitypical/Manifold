//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public static func alphaEquivalent(left: Self, _ right: Self, _ environment: [Name:Self], var _ visited: Set<Name> = []) -> Bool {
		let recur: (Self, Self) -> Bool = {
			alphaEquivalent($0, $1, environment, visited)
		}

		let normalize: (Self, Set<Name>) -> (Self, Set<Name>) = { (term, var visited) in
			(term.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited), visited)
		}

		let (left, lnames) = normalize(left, visited)
		let (right, rnames) = normalize(right, visited)
		visited.unionInPlace(lnames)
		visited.unionInPlace(rnames)

		switch (left.out, right.out) {
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

		default:
			return false
		}
	}
}
