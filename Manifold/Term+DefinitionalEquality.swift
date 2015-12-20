//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term], var visited: Set<Term> = []) -> Term? {
		let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: false, visited: visited)
		let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: false, visited: visited)
		visited.unionInPlace(visitedLeft)
		visited.unionInPlace(visitedRight)

		if leftʹ == rightʹ { return rightʹ }

		switch (leftʹ.out, rightʹ.out) {
		case (.Implicit, _):
			return rightʹ

		case (_, .Implicit):
			return leftʹ

		case (.Type, .Type):
			return rightʹ

		case let (.Application(a1, a2), .Application(b1, b2)):
			guard let first = equate(a1, b1, environment, visited: visited), second = equate(a2, b2, environment, visited: visited) else { return nil }
			return .Application(first, second)

		case let (.Lambda(_, a1, a2), .Lambda(i, b1, b2)):
			guard let type = equate(a1, b1, environment, visited: visited), body = equate(a2, b2, environment, visited: visited) else { return nil }
			return .Lambda(i, type, body)

		default:
			return nil
		}
	}
}
