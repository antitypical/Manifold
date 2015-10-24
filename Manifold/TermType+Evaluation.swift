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
		default:
			return self
		}
	}
}
