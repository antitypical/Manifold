//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func evaluate(environment: [Name:Term] = [:]) throws -> Term {
		switch out {
		case let .Variable(i):
			if let found = environment[i] {
				return found
			}
			throw "Illegal free variable \(i)"
		case let .Application(a, b):
			let a = try a.evaluate(environment)
			if case let .Lambda(i, _, body) = a.out {
				return try body.substitute(i, b.evaluate(environment)).evaluate(environment)
			}
			throw "Illegal application of non-lambda term \(a) to \(b)"
		default:
			return self
		}
	}
}
