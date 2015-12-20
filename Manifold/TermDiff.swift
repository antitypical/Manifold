//  Copyright © 2015 Rob Rix. All rights reserved.

enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)

	init(_ term: Term) {
		self = .Roll(term.out.map(TermDiff.init))
	}

	init(_ left: Term, _ right: Term, _ environment: [Name:Term], var _ visited: Set<Term> = []) {
		func unify(left: Term, _ right: Term) -> TermDiff {
			let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			visited.unionInPlace(visitedLeft)
			let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			visited.unionInPlace(visitedRight)

			guard leftʹ != rightʹ else { return TermDiff(right) }

			switch (leftʹ.out, rightʹ.out) {
			case (.Implicit, _):
				return TermDiff(right)
			case (_, .Implicit):
				return TermDiff(left)

			case (.Type, .Type):
				return TermDiff(right)

			case let (.Application(a1, b1), .Application(a2, b2)):
				return .Roll(.Application(unify(a1, a2), unify(b1, b2)))

			case let (.Lambda(_, type1, body1), .Lambda(i, type2, body2)):
				return .Roll(.Lambda(i, unify(type1, type2), unify(body1, body2)))

			default:
				return .Patch(left, right)
			}
		}
		self = unify(left, right)
	}
}
