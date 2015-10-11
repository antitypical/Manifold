//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType, Recur: Equatable {
	public typealias Context = [Name: Expression]

	public func inferType(environment: Environment = [:], _ context: Context = [:]) -> Either<Error, Expression> {
		return annotate(inferTypeUnannotated(environment, context))
	}

	public func inferTypeUnannotated(environment: Environment = [:], _ context: Context = [:]) -> Either<Error, Expression> {
		switch destructured {
		// Inference rules.
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
							: Expression.lambda(.BooleanType) { .If($0, Recur(a), Recur(b)) }
					}

		case .UnitType, .BooleanType:
			return .right(.Type(0))
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return context[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(i)")

		case let .Lambda(i, type, body):
			return type.checkIsType(environment, context)
				>> body.inferType(environment, context + [ .Local(i): type ])
					.map { Expression.lambda(Recur(type), const(Recur($0))) }

		case let .Product(a, b):
			return (a.inferType(environment, context) &&& b.inferType(environment, context))
				.map { A, B in Expression.lambda(Recur(A), const(Recur(B))) }

		case let .Application(a, b):
			return a.inferType(environment, context)
				.flatMap { A in
					A.weakHeadNormalForm(environment).analysis(
						ifLambda: { i, type, body in
							b.checkType(type.out, environment, context)
								.map { _ in body.out.substitute(i, b) }
						},
						otherwise: const(Either.Left("illegal application of \(a) : \(A) to \(b)")))
				}

		case let .Projection(term, branch):
			return term.inferType(environment, context)
				.flatMap { type in
					type.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.out.substitute(i, A.out) : A.out)
						},
						otherwise: const(Either.Left("illegal projection of field \(branch ? 1 : 0) of non-product value \(term) of type \(type)")))
				}

		case let .Annotation(term, type):
			return term.checkType(type, environment, context)
				.map(const(type))
		}
	}
}


import Either
import Prelude
