//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType, Recur: Equatable {
	public func checkIsType(context: Context) -> Either<Error, Expression> {
		return checkType(.Type(0), context: context)
	}

	public func checkType(against: Expression, context: Context = [:]) -> Either<Error, Expression> {
		switch (destructured, against.destructured) {
		case (.Type, .Type):
			return .Right(against)

		case let (.Lambda(i, .Some(type), body), .Type):
			return annotate(type.checkIsType(context)
				>> body.checkType(against, context: context + [ Name.Local(i) : type ])
					.map(const(against)))

		case let (.Product(tag, payload), .Lambda(i, .Some(tagType), body)):
			return annotate(tagType.checkIsType(context)
				>> (tag.checkType(tagType, context: context)
				>> payload.checkType(body.substitute(i, tag), context: context)
					.map(const(against))))

		default:
			return annotate(inferType(context)
				.flatMap { inferred in
					inferred == against
						? Either.right(inferred)
						: Either.left("Type mismatch: expected \(self) to be of type \(against), but it was actually of type \(inferred) in context \(Expression.toString(context))")
				})
		}
	}

	private static func toString(context: Context) -> String {
		let keys = lazy(context.keys.sort())
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = ",\n\t".join(keys.map { "\(String($0, paddedTo: maxLength, with: padding)) : \(context[$0]!)" })

		return "[\n\t\(formattedContext)\n]"
	}

	func annotate<T>(either: Either<Error, T>) -> Either<Error, T> {
		return either.either(ifLeft: { $0.map { "\($0)\nin: \(self)" } } >>> Either.left, ifRight: Either.right)
	}
}


import Either
import Prelude
