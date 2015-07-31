//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType, Recur: Equatable {
	public typealias Context = [Name: Expression]

	public func inferType(context: Context = [:]) -> Either<Error, Expression> {
		switch destructured {
		// Inference rules.
		case .Unit:
			return .right(.UnitType)
		case .Boolean:
			return .right(.BooleanType)

		case let .If(condition, then, `else`):
			return condition.checkType(.BooleanType, context: context)
				.flatMap { _ in
					(then.inferType(context) &&& `else`.inferType(context))
						.map { a, b in
							a == b
								? a
								: Expression.lambda(Recur(.BooleanType)) { Recur(.If($0, Recur(a), Recur(b))) }
						}
				}

		case .UnitType, .BooleanType:
			return .right(.Type(0))
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return context[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(i)")

		case let .Lambda(i, type, body):
			return type.checkIsType(context)
				.flatMap { _ in
					body.inferType(context + [ .Local(i): type ])
						.map { Expression.lambda(Recur(type), const(Recur($0))) }
				}

		case let .Product(a, b):
			return (a.inferType(context) &&& b.inferType(context))
				.map { A, B in Expression.lambda(Recur(A), const(Recur(B))) }

		case let .Application(a, b):
			return a.inferType(context)
				.flatMap { A in
					A.analysis(
						ifLambda: { i, type, body in
							b.checkType(type.out, context: context)
								.map { _ in body.out.substitute(i, b) }
						},
						otherwise: const(Either.Left("illegal application of \(a) : \(A) to \(b)")))
				}

		case let .Projection(term, branch):
			return term.inferType(context)
				.flatMap { type in
					type.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.out.substitute(i, A.out) : A.out)
						},
						otherwise: const(Either.Left("illegal projection of field \(branch ? 1 : 0) of non-product value \(term) of type \(type)")))
				}

		case let .Annotation(term, type):
			return term.checkType(type, context: context)
				.map(const(type))

		case let .Axiom(_, type):
			return Either.right(type)

		default:
			return Either.left("Cannot infer type for \(self). Try annotating?")
		}
	}
}


import Either
import Prelude
