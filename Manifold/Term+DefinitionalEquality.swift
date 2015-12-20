//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term]) -> Term? {
		let normalize: Term -> Term = { term in
			term.weakHeadNormalForm(environment, shouldRecur: false)
		}

		let left = normalize(left)
		let right = normalize(right)

		if left == right { return right }

		switch (left.out, right.out) {
		case (.Implicit, _):
			return right

		case (_, .Implicit):
			return left

		case (.Type, .Type):
			return right

		case let (.Application(a1, a2), .Application(b1, b2)):
			guard let first = equate(a1, b1, environment), second = equate(a2, b2, environment) else { return nil }
			return .Application(first, second)

		case let (.Lambda(_, a1, a2), .Lambda(i, b1, b2)):
			guard let type = equate(a1, b1, environment), body = equate(a2, b2, environment) else { return nil }
			return .Lambda(i, type, body)

		default:
			return nil
		}
	}
}
