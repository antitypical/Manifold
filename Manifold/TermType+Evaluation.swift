//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func evaluate(environment: [Name:Self] = [:]) -> Self {
		switch out {
		case let .Variable(i):
			if let found = environment[i] {
				return found
			}
			fatalError("Illegal free variable \(i)")
		case let .Application(a, b):
			let a = a.evaluate(environment)
			if case let .Lambda(i, _, body) = a.out {
				return body.substitute(i, b.evaluate(environment)).evaluate(environment)
			}
			fatalError("Illegal application of non-lambda term \(a) to \(b)")
		case let .If(condition, then, `else`):
			let condition = condition.evaluate(environment)
			if case let .Boolean(boolean) = condition.out {
				return boolean
					? then.evaluate(environment)
					: `else`.evaluate(environment)
			}
			fatalError("Illegal branch on non-boolean term \(condition)")
		case let .Annotation(term, _):
			return term.evaluate(environment)
		default:
			return self
		}
	}
}
