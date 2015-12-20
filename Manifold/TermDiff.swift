//  Copyright © 2015 Rob Rix. All rights reserved.

enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)

	init(_ term: Term) {
		self = .Roll(term.out.map(TermDiff.init))
	}

	init(_ left: Term, _ right: Term, _ environment: [Name:Term], var _ visited: Set<Term> = []) {
		let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
		visited.unionInPlace(visitedLeft)
		let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
		visited.unionInPlace(visitedRight)

		guard leftʹ != rightʹ else { self = TermDiff(right) ; return }

		switch (leftʹ.out, rightʹ.out) {
		case (.Implicit, _):
			self = TermDiff(right)
		case (_, .Implicit):
			self = TermDiff(left)

		case (.Type, .Type):
			self = TermDiff(right)

		case let (.Application(a1, b1), .Application(a2, b2)):
			self = .Roll(.Application(TermDiff(a1, a2, environment, visited), TermDiff(b1, b2, environment, visited)))

		case let (.Lambda(_, type1, body1), .Lambda(i, type2, body2)):
			self = .Roll(.Lambda(i, TermDiff(type1, type2, environment, visited), TermDiff(body1, body2, environment, visited)))

		default:
			self = .Patch(left, right)
		}
	}
}
