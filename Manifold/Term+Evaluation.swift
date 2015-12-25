//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func evaluate(environment: [Name:Term] = [:]) throws -> Term {
		switch scoping {
		case let .Variable(i):
			guard let found = environment[i] else { throw "Illegal free variable \(i)" }
			return found

		case let .Identity(.Application(a, b)):
			let aʹ = try a.evaluate(environment)
			switch aʹ.out {
			case let .Lambda(i, _, body):
				return try body.substitute(i, b.evaluate(environment)).evaluate(environment)

			case let .Embedded((_, evaluator) as (String, Term throws -> Term), _, _):
				return try evaluator(b.evaluate(environment)).evaluate(environment)

			default:
				throw "Illegal application of non-lambda term \(a)↓\(aʹ) to \(b)"
			}

		default:
			return self
		}
	}
}
