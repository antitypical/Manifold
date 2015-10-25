//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func checkIsType(environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Self> {
		return checkType(.Type, environment, context)
	}

	public func checkType(against: Self, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Self> {
		return annotate(checkTypeUnannotated(against, environment, context).map(const(against)), against)
	}

	private func checkTypeUnannotated(against: Self, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Self> {
		switch (out, against.weakHeadNormalForm(environment).out) {
		case (.Type, .Type):
			return .Right(against)

		case let (.Lambda(i, type1, body), .Lambda(j, type2, bodyType)) where Self.equate(type1, type2, environment):
			return type1.checkIsType(environment, context)
				>> body.checkType(bodyType.substitute(j, .Variable(.Local(i))), environment, context + [ Name.Local(i) : type1 ])

		case let (.Lambda(i, type, body), .Type):
			return type.checkIsType(environment, context)
				>> body.checkIsType(environment, context + [ Name.Local(i) : type ])

		default:
			return inferType(environment, context)
				.flatMap { inferred in
					Self.equate(inferred, against, environment)
						? Either.Right(inferred)
						: Either.Left("Type mismatch: expected '\(self)' to be of type '\(against)', but it was actually of type '\(inferred)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))")
				}
		}
	}

	static func toString(table: [Name:Self], separator: String) -> String {
		let keys = table.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String(String($0), paddedTo: maxLength, with: padding)) \(separator) \(table[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}

	func annotate<T>(either: Either<String, T>, _ against: Self? = nil) -> Either<String, T> {
		return either.either(
			ifLeft: { "\($0)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?") } >>> Either.Left,
			ifRight: Either.Right)
	}
}


import Either
import Prelude
