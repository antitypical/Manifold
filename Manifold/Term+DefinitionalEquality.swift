//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term) -> Bool {
		return equate(left, right, [:]) != nil
	}

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

		case let (.Identity(.Embedded(a1, _, t1)), .Identity(.Embedded(a2, eq, t2))):
			guard let t = equate(t1, t2, environment, visited: visited) where eq(a1, a2) else { return nil }
			return .Embedded(a2, eq, t)

		case let (.Abstraction(name1, scope1), .Abstraction(name2, scope2)):
			let fresh = Name.fresh(scope1.freeVariables.union(scope1.boundVariables).union(scope2.freeVariables).union(scope2.boundVariables))
			guard let scope = equate(scope1.rename(name1, fresh), scope2.rename(name2, fresh), environment, visited: visited) else { return nil }
			return .Abstraction(name2, scope.rename(fresh, name2))

		case let (.Abstraction(name, scope), _) where !scope.freeVariables.contains(name):
			return equate(scope, rightʹ, environment, visited: visited)
			
		case let (_, .Abstraction(name, scope)) where !scope.freeVariables.contains(name):
			return equate(leftʹ, scope, environment, visited: visited)

		default:
			return nil
		}
	}
}
