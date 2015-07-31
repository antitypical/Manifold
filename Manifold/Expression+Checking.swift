//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType, Recur: Equatable {
		public func checkType(against: Expression, context: Context = [:]) -> Either<Error, Expression> {
		return (against.isType
				? Either.Right(against)
				: against.checkType(.Type(0), context: context))
			.map { _ in against.evaluate(context) }
			.flatMap { against in
				inferType(context)
					.map { $0.evaluate(context) }
					.flatMap { (type: Expression) -> Either<Error, Expression> in
						if case let (.Product(tag, payload), .Lambda(i, tagType, body)) = (self, against) {
							return tagType.out.checkType(.Type(0), context: context)
								.flatMap { _ in
									tag.out.checkType(tagType.out, context: context)
										.flatMap { _ in
											payload.out.checkType(body.out.substitute(i, tag.out), context: context)
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
