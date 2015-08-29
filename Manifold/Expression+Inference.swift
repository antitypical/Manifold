//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType, Recur: Equatable {
	public typealias Context = [Name: Expression]

	public func inferType(environment: Environment = [:], _ context: Context = [:]) -> Either<Error, Expression> {
		switch destructured {
		// Inference rules.
		case .Unit:
			return .right(.UnitType)

		case .UnitType:
			return .right(.Type(0))
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return annotate(context[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(i)"))

		case let .Lambda(i, type, body):
			return annotate(type.checkIsType(environment, context)
				>> body.inferType(environment, context + [ .Local(i): type ])
					.map { Expression.lambda(Recur(type), const(Recur($0))) })

		case let .Product(a, b):
			return annotate((a.inferType(environment, context) &&& b.inferType(environment, context))
				.map { A, B in Expression.lambda(Recur(A), const(Recur(B))) })

		case let .Application(a, b):
			return annotate(a.inferType(environment, context)
				.flatMap { A in
					A.weakHeadNormalForm(environment).analysis(
						ifLambda: { i, type, body in
							b.checkType(type.out, environment, context)
								.map { _ in body.out.substitute(i, b) }
						},
						otherwise: const(Either.Left("illegal application of \(a) : \(A) to \(b)")))
				})

		case let .Projection(term, branch):
			return annotate(term.inferType(environment, context)
				.flatMap { type in
					type.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.out.substitute(i, A.out) : A.out)
						},
						otherwise: const(Either.Left("illegal projection of field \(branch ? 1 : 0) of non-product value \(term) of type \(type)")))
				})

		case let .Annotation(term, type):
			return annotate(term.checkType(type, environment, context)
				.map(const(type)))

		case let .Tag(_, n):
			return Either.Right(.Enumeration(n))

		case let .Switch(tag, labels, type):
			return annotate(tag.checkType(.Enumeration(labels.count), environment, context)
				>> (type.checkIsType(environment, context)
				>>- { type in
					labels.lazy
						.map { $0.checkType(type, environment, context) }
						.reduce(Either.Right(())) {
							($0 &&& $1).map(const(()))
						}
						>> Either.Right(type)
				}))

		default:
			return Either.Left("Cannot infer type for \(self). Try annotating?")
		}
	}
}


import Either
import Prelude
