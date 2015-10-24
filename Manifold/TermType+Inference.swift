//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func inferType(environment: [Name:Self] = [:], _ context: [Name:Self] = [:]) -> Either<String, Self> {
		return annotate(inferTypeUnannotated(environment, context))
	}

	private func inferTypeUnannotated(environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Self> {
		switch out {
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return context[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(i) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")

		case let .Lambda(i, type, body):
			return type.checkIsType(environment, context)
				>> body.inferType(environment, context + [ .Local(i): type ])
					.map { b in .lambda(type, { b.substitute(i, $0) }) }

		case let .Application(a, b):
			return a.inferType(environment, context)
				.flatMap { A in
					switch A.weakHeadNormalForm(environment).out {
					case let .Lambda(i, type, body):
						return b.checkType(type, environment, context).map { _ in body.substitute(i, b) }
					default:
						return Either.Left("Illegal application of \(a) : \(A) to \(b) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")
					}
				}
		}
	}
}


import Either
import Prelude
