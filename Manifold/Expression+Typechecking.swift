//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType, Recur: Equatable {
	// MARK: Typechecking

	public typealias Context = [Name: Expression]

	public func inferType(context: Context = [:]) -> Either<Error, Expression> {
		return typecheck(context)
	}

	public func typecheck(context: Context = [:]) -> Either<Error, Expression> {
		switch destructured {
		// Inference rules.
		case .Unit:
			return .right(.UnitType)
		case .Boolean:
			return .right(.BooleanType)

		case let .If(condition, then, `else`):
			return condition.typecheck(context, against: .BooleanType)
				.flatMap { _ in
					(then.typecheck(context) &&& `else`.typecheck(context))
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
			return type.typecheck(context, against: .Type(0))
				.flatMap { _ in
					body.typecheck(context + [ .Local(i): type ])
						.map { Expression.lambda(Recur(type), const(Recur($0))) }
				}

		case let .Product(a, b):
			return (a.typecheck(context) &&& b.typecheck(context))
				.map { A, B in Expression.lambda(Recur(A), const(Recur(B))) }

		case let .Application(a, b):
			return a.typecheck(context)
				.flatMap { A in
					A.analysis(
						ifLambda: { i, type, body in
							b.typecheck(context, against: type.out)
								.map { _ in body.out.substitute(i, b) }
						},
						otherwise: const(Either.Left("illegal application of \(a) : \(A) to \(b)")))
				}

		case let .Projection(term, branch):
			return term.typecheck(context)
				.flatMap { type in
					type.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.out.substitute(i, A.out) : A.out)
						},
						otherwise: const(Either.Left("illegal projection of field \(branch ? 1 : 0) of non-product value \(term) of type \(type)")))
				}

		case let .Annotation(term, type):
			return term.typecheck(context, against: type)
				.map(const(type))

		case let .Axiom(_, type):
			return Either.right(type)
		}
	}

	public func checkType(against: Expression, context: Context = [:]) -> Either<Error, Expression> {
		return typecheck(context, against: against)
	}

	public func typecheck(context: Context, against: Expression) -> Either<Error, Expression> {
		return (against.isType
				? Either.Right(against)
				: against.typecheck(context, against: .Type(0)))
			.map { _ in against.evaluate(context) }
			.flatMap { against in
				typecheck(context)
					.map { $0.evaluate(context) }
					.flatMap { (type: Expression) -> Either<Error, Expression> in
						if case let (.Product(tag, payload), .Lambda(i, tagType, body)) = (self, against) {
							return tagType.out.typecheck(context, against: .Type(0))
								.flatMap { _ in
									tag.out.typecheck(context, against: tagType.out)
										.flatMap { _ in
											payload.out.typecheck(context, against: body.out.substitute(i, tag.out))
												.map(const(type))
										}
								}
						}

						if case let .Lambda(_, _, returnType) = type where against.isType && returnType.out.isType {
							return .Right(type)
						}

						if type == against || against == .Type(0) && type.isType {
							return .Right(type)
						}

						let keys = lazy(context.keys.sort())
						let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
						let padding: Character = " "
						let formattedContext = ",\n\t".join(keys.map { "\(String($0, paddedTo: maxLength, with: padding)) : \(context[$0]!)" })

						return .Left("Type mismatch: expected \(self) to be of type \(against), but it was actually of type \(type) in context [\n\t\(formattedContext)\n]")
					}
			}
	}
}


import Either
import Prelude
