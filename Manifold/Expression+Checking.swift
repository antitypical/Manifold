//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType, Recur: Equatable {
	public func checkIsType(environment: Environment, _ context: Context) -> Either<Error, Expression> {
		return checkType(.Type(0), environment, context)
	}

	public func checkType(against: Expression, _ environment: Environment = [:], _ context: Context = [:]) -> Either<Error, Expression> {
		switch (destructured, against.weakHeadNormalForm(environment).destructured) {
		case (.Type, .Type):
			return .Right(against)

		case let (.Lambda(i, type, body), .Type):
			return annotate(type.checkIsType(environment, context)
				>> body.checkType(against, environment, context + [ Name.Local(i) : type ])
					.map(const(against)))

		case let (.If(condition, then, otherwise), _):
			return annotate((condition.checkType(.BooleanType, environment, context)
				>> then.checkType(against, environment, context))
				>> otherwise.checkType(against, environment, context)
					.map(const(against)))

		case let (.Product(a, b), .Type):
			return annotate(a.checkIsType(environment, context)
				>> b.checkIsType(environment, context)
					.map(const(against)))

		case let (.Product(tag, payload), .Lambda(i, tagType, body)):
			return annotate(tagType.checkIsType(environment, context)
				>> (tag.checkType(tagType, environment, context)
				>> payload.checkType(body.substitute(i, tag).weakHeadNormalForm(environment), environment, context)
					.map(const(against))))

		default:
			return annotate(inferType(environment, context)
				.flatMap { inferred in
					Expression.alphaEquivalent(inferred, against, environment)
						? Either.right(inferred)
						: Either.left("Type mismatch: expected '\(self)' to be of type '\(against)', but it was actually of type '\(inferred)' in context \(Expression.toString(context))")
				})
		}
	}

	private static func toString(context: Context) -> String {
		let keys = context.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String($0, paddedTo: maxLength, with: padding)) : \(context[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}

	func annotate<T>(either: Either<Error, T>) -> Either<Error, T> {
		return either.either(ifLeft: { $0.map { "\($0)\nin: \(self)" } } >>> Either.left, ifRight: Either.right)
	}
}


import Either
import Prelude
