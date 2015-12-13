//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func evaluate(environment: [Name:Term] = [:]) throws -> Term {
		switch out {
		case let .Variable(i):
			guard let found = environment[i] else { throw "Illegal free variable \(i)" }
			return found

		case let .Application(a, b):
			let a = try a.evaluate(environment)
			guard case let .Lambda(i, _, body) = a.out else { throw "Illegal application of non-lambda term \(a) to \(b)" }
			return try body.substitute(i, b.evaluate(environment)).evaluate(environment)

		default:
			return self
		}
	}
}
