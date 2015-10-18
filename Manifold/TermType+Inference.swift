//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func inferType(environment: [Name:Self] = [:], _ context: [Name:Self] = [:]) -> Either<Error, Self> {
		return annotate(inferTypeUnannotated(environment, context))
	}

	public func inferTypeUnannotated(environment: [Name:Self] = [:], _ context: [Name:Self] = [:]) -> Either<Error, Self> {
		switch out {
		case .Unit:
			return .right(.UnitType)
		case .Boolean:
			return .right(.BooleanType)

		case let .If(condition, then, `else`):
			return condition.checkType(.BooleanType, environment, context)
				>> (then.inferType(environment, context) &&& `else`.inferType(environment, context))
					.map { a, b in
						a == b
							? a
							: Self.lambda(.BooleanType) { .If($0, a, b) }
			}

		case .UnitType, .BooleanType:
			return .right(.Type(0))
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return context[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(Self.describe(i)) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")

		case let .Lambda(i, type, body):
			return type.checkIsType(environment, context)
				>> body.inferType(environment, context + [ .Local(i): type ])
					.map { b in .lambda(type, { b.substitute(i, $0) }) }

		case let .Product(a, b):
			return (a.inferType(environment, context) &&& b.inferType(environment, context))
				.map { A, B in .lambda(A, const(B)) }

		case let .Application(a, b):
			return a.inferType(environment, context)
				.flatMap { A in
					A.weakHeadNormalForm(environment).out.analysis(
						ifLambda: { i, type, body in
							b.checkType(type, environment, context)
								.map { _ in body.substitute(i, b) }
						},
						otherwise: const(Either.Left("Illegal application of \(a) : \(A) to \(b) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")))
			}

		case let .Projection(term, branch):
			return term.inferType(environment, context)
				.flatMap { type in
					type.out.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.substitute(i, A) : A)
						},
						otherwise: const(Either.Left("Illegal projection of field \(branch ? 1 : 0) of non-product value \(term) of type \(type) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")))
			}

		case let .Annotation(term, type):
			return term.checkType(type, environment, context)
				.map(const(type))
		}
	}
}


import Either
import Prelude
