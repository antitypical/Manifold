//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term], var _ visited: Set<Name> = []) -> Bool {
		let recur: (Term, Term) -> Bool = {
			equate($0, $1, environment, visited)
		}

		let normalize: (Term, Set<Name>) -> (Term, Set<Name>) = { (term, var visited) in
			(term.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited), visited)
		}

		let (left, lnames) = normalize(left, visited)
		let (right, rnames) = normalize(right, visited)
		visited.unionInPlace(lnames)
		visited.unionInPlace(rnames)

		if left == right { return right }

		switch (left.out, right.out) {
		case (.Type, .Type):
			return true

		case let (.Variable(a), .Variable(b)):
			return a == b

		case let (.Application(a1, a2), .Application(b1, b2)):
			return recur(a1, b1) && recur(a2, b2)

		case let (.Lambda(_, .Some(a1), a2), .Lambda(_, .Some(b1), b2)):
			return recur(a1, b1) && recur(a2, b2)

		default:
			return false
		}
	}
}
