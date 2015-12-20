//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func weakHeadNormalForm(environment: [Name:Term], shouldRecur: Bool = true) -> Term {
		return weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: []).0
	}

	private func weakHeadNormalForm(environment: [Name:Term], shouldRecur: Bool = true, var visited: Set<Term> = []) -> (Term, Set<Term>) {
		switch out {
		case let .Variable(name) where shouldRecur:
			return environment[name].map { $0.weakHeadNormalForm(environment, shouldRecur: false, visited: visited) }
				?? (self, visited)

		case let .Variable(name):
			return (environment[name] ?? self, visited)

		case let .Application(t1, t2):
			let (t1, visited) = t1.weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: visited)
			switch t1.out {
			case let .Lambda(i, _, body):
				return body.substitute(i, t2).weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: visited)

			case let .Variable(name) where shouldRecur:
				let (t2, visited) = t2.weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: visited)
				return environment[name].map { Term.Application($0, t2).weakHeadNormalForm(environment, shouldRecur: false, visited: visited) }
					?? (.Application(t1, t2), visited)

			default:
				return (.Application(t1, t2), visited)
			}

		default:
			return (self, visited)
		}
	}
}
