//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public typealias Environment = [Name:Self]
	public typealias Context = [Name:Self]

	public func weakHeadNormalForm(environment: Environment, shouldRecur: Bool = true) -> Self {
		var visited: Set<Name> = []
		return weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
	}

	private func weakHeadNormalForm(environment: Environment, shouldRecur: Bool = true, inout visited: Set<Name>) -> Self {
		let unfold: Self -> Self = {
			$0.weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
		}
		let done: Self -> Self = {
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

		case let .Projection(a, b):
			let a = unfold(a)
			switch a.out {
			case let .Product(t1, t2):
				return unfold(b ? t1 : t2)

			default:
				return .Projection(a, b)
			}

		case let .If(condition, then, `else`):
			let condition = unfold(condition)
			switch condition.out {
			case let .Boolean(flag):
				return unfold(flag ? then : `else`)

			default:
				return .If(condition, then, `else`)
			}

		default:
			return self
		}
	}
}