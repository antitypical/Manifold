//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public typealias Environment = [Name: Expression]

	public func evaluate(environment: Environment = [:]) -> Expression {
		switch destructured {
		case let .Variable(i):
			if let found = environment[i] {
				return found
			}
			fatalError("Illegal free variable \(i)")
		case let .Application(a, b):
			let a = a.evaluate(environment)
			if let (i, _, body) = a.lambda {
				return body.out.substitute(i, b.evaluate(environment)).evaluate(environment)
			}
			fatalError("Illegal application of non-lambda term \(a) to \(b)")
		case let .Projection(a, b):
			let a = a.evaluate(environment)
			if let (a0, a1) = a.product {
				return (b ? a1 : a0).out
			}
			fatalError("Illegal projection of non-product term \(a) field \(b ? 1 : 0)")
		case let .Annotation(term, _):
			return term.evaluate(environment)

		case let .Switch(tag, labels, _):
			switch tag.evaluate(environment) {
			case let .Tag(_, n) where n != labels.count:
				fatalError("Illegal switch on \(n)-point domain with \(labels.count) cases")
			case let .Tag(m, n) where m >= n:
				fatalError("Illegal tag \(m) >= \(n) in \(n)-point domain")
			case let .Tag(m, _):
				return labels[m].evaluate(environment)
			default:
				fatalError("Illegal switch on non-tag term \(tag)")
			}

		default:
			return self
		}
	}
}
