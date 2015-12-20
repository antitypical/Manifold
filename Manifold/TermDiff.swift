//  Copyright © 2015 Rob Rix. All rights reserved.

enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)

	init(_ term: Term) {
		self = .Roll(term.out.map(TermDiff.init))
	}

	init(_ left: Term, _ right: Term, _ environment: [Name:Term], var _ visited: Set<Term> = []) {
		func unify(left: Term, _ right: Term) -> (TermDiff, Set<Term>) {
			let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			visited.unionInPlace(visitedLeft)
			let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			visited.unionInPlace(visitedRight)

			guard leftʹ != rightʹ else { return (TermDiff(right), visited) }

			switch (leftʹ.out, rightʹ.out) {
			case (.Implicit, _):
				return (TermDiff(right), visited)
			case (_, .Implicit):
				return (TermDiff(left), visited)

			case (.Type, .Type):
				return (TermDiff(right), visited)

			case let (.Application(a1, b1), .Application(a2, b2)):
				let (a, visitedA) = unify(a1, a2)
				visited.unionInPlace(visitedA)
				let (b, visitedB) = unify(b1, b2)
				visited.unionInPlace(visitedB)
				return (.Roll(.Application(a, b)), visited)

			case let (.Lambda(_, type1, body1), .Lambda(i, type2, body2)):
				let (type, visitedType) = unify(type1, type2)
				visited.unionInPlace(visitedType)
				let (body, visitedBody) = unify(body1, body2)
				visited.unionInPlace(visitedBody)
				return (.Roll(.Lambda(i, type, body)), visited)

			default:
				return (.Patch(left, right), visited)
			}
		}
		(self, _) = unify(left, right)
	}
}
