//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term], var visited: Set<Term> = []) -> Term? {
		if left == right { return right }

		let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: false, visited: visited)
		let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: false, visited: visited)
		visited.unionInPlace(visitedLeft)
		visited.unionInPlace(visitedRight)

		if leftʹ == rightʹ { return rightʹ }

		switch (leftʹ.out, rightʹ.out) {
		case (.Identity(.Implicit), _):
			return rightʹ

		case (_, .Identity(.Implicit)):
			return leftʹ

		case (.Identity(.Type), .Identity(.Type)):
			return rightʹ

		case let (.Identity(.Application(a1, a2)), .Identity(.Application(b1, b2))):
			guard let first = equate(a1, b1, environment, visited: visited), second = equate(a2, b2, environment, visited: visited) else { return nil }
			return .Application(first, second)

		case let (.Identity(.Lambda(a1, a2)), .Identity(.Lambda(b1, b2))):
			guard let type = equate(a1, b1, environment, visited: visited), body = equate(a2, b2, environment, visited: visited) else { return nil }
			return .Lambda(type, body)

		case let (.Abstraction(_, scope1), .Abstraction(name, scope2)):
			guard let scope = equate(scope1, scope2, environment, visited: visited) else { return nil }
			return .Abstraction(name, scope)

		default:
			return nil
		}
	}
}
