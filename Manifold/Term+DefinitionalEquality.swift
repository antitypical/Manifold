//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term], var _ visited: Set<Name> = []) -> Term? {
		let recur: (Term, Term) -> Term? = {
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
			return right

		case let (.Application(a1, a2), .Application(b1, b2)):
			if let first = recur(a1, b1), second = recur(a2, b2) {
				return .Application(first, second)
			}
			return nil

		case let (.Lambda(_, .Some(a1), a2), .Lambda(i, .Some(b1), b2)):
			if let type = recur(a1, b1), body = recur(a2, b2) {
				return .Lambda(i, type, body)
			}
			return nil

		default:
			return nil
		}
	}
}
