//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public static func equate(left: Self, _ right: Self, _ environment: [Name:Self], var _ visited: Set<Name> = []) -> Bool {
		if left == right { return true }

		let recur: (Self, Self) -> Bool = {
			equate($0, $1, environment, visited)
		}

		let normalize: (Self, Set<Name>) -> (Self, Set<Name>) = { (term, var visited) in
			(term.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited), visited)
		}

		let (left, lnames) = normalize(left, visited)
		let (right, rnames) = normalize(right, visited)
		visited.unionInPlace(lnames)
		visited.unionInPlace(rnames)

		switch (left.out, right.out) {
		case (.Type, .Type):
			return true

		case let (.Variable(a), .Variable(b)):
			return a == b

		case let (.Application(a1, a2), .Application(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Lambda(_, a1, a2), .Lambda(_, b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		default:
			return false
		}
	}
}
