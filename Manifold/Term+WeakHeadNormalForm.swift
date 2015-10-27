//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func weakHeadNormalForm(environment: [Name:Term], shouldRecur: Bool = true) -> Term {
		var visited: Set<Name> = []
		return weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
	}

	func weakHeadNormalForm(environment: [Name:Term], shouldRecur: Bool = true, inout visited: Set<Name>) -> Term {
		let unfold: Term -> Term = {
			$0.weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
		}
		let done: Term -> Term = {
			$0.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited)
		}
		switch out {
		case let .Variable(name) where shouldRecur && !visited.contains(name):
			visited.insert(name)
			return environment[name].map(done) ?? self

		case let .Variable(name) where !visited.contains(name):
			visited.insert(name)
			return environment[name] ?? self

		case let .Application(t1, t2):
			let t1 = unfold(t1)
			switch t1.out {
			case let .Lambda(i, _, body):
				return unfold(body.substitute(i, t2))

			case let .Variable(name) where shouldRecur:
				visited.insert(name)
				let t2 = unfold(t2)
				return environment[name].map { .Application($0, t2) }.map(done) ?? .Application(t1, t2)

			default:
				return .Application(t1, t2)
			}

		default:
			return self
		}
	}
}