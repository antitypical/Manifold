//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func evaluate(environment: [Name:Term] = [:]) throws -> Term {
		switch out {
		case let .Variable(i):
			guard let found = environment[i] else { throw "Illegal free variable \(i)" }
			return found

		case let .Identity(.Application(a, b)):
			let aʹ = try a.evaluate(environment)
			switch aʹ.out {
			case let .Identity(.Lambda(_, body)):
				guard let (name, scope) = body.scope else { return try body.evaluate(environment) }
				return try scope.substitute(name, with: b.evaluate(environment)).evaluate(environment)

			case let .Identity(.Embedded((_, evaluator) as (String, Term throws -> Term), _, _)):
				return try evaluator(b.evaluate(environment)).evaluate(environment)

			default:
				throw "Illegal application of non-lambda term \(a)↓\(aʹ) to \(b)"
			}

		default:
			return self
		}
	}
}
