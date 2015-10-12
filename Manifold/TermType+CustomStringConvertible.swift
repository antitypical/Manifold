//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public static func describe(name: Name) -> String {
		let alphabet = "abcdefghijklmnopqrstuvwxyz"
		return name.analysis(
			ifGlobal: id,
			ifLocal: { renderNumerals($0, alphabet) })
	}

	private static func renderNumerals(n: Int, _ alphabet: String) -> String {
		return n.digits(alphabet.characters.count).lazy.map { String(atModular(alphabet.characters, offset: $0)) }.joinWithSeparator("")
	}

	public var description: String {
		let subscripts = "₀₁₂₃₄₅₆₇₈₉"
		return para {
			switch $0 {
			case .Unit:
				return "()"
			case .UnitType:
				return "Unit"

			case let .Type(n) where n == 0:
				return "Type"
			case let .Type(n):
				return "Type" + Self.renderNumerals(n, subscripts)

			case let .Variable(name):
				return Self.describe(name)

			case let .Application((_, a), (_, b)):
				return "(\(a) \(b))"

			case let .Lambda(variable, (_, type), (b, body)):
				return b.freeVariables.contains(variable)
					? "λ \(Self.describe(.Local(variable))) : \(type) . \(body)"
					: "\(type) → \(body)"

			case let .Projection((_, term), branch):
				return "\(term).\(branch ? 1 : 0)"

			case let .Product((_, a), (_, b)):
				return "(\(a) × \(b))"

			case .BooleanType:
				return "Boolean"
			case let .Boolean(b):
				return String(b)

			case let .If((_, condition), (_, then), (_, `else`)):
				return "if \(condition) then \(then) else \(`else`)"

			case let .Annotation((_, term), (_, type)):
				return "(\(term) : \(type))"
			}
		} (self)
	}
}

private func atModular<C: CollectionType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	return collection[collection.startIndex.advancedBy(offset % collection.startIndex.distanceTo(collection.endIndex), limit: collection.endIndex)]
}


import Prelude
