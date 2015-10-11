//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public var description: String {
		let renderNumerals: (Int, String) -> String = { n, alphabet in
			n.digits(alphabet.characters.count).lazy.map { String(atModular(alphabet.characters, offset: $0)) }.joinWithSeparator("")
		}
		let alphabet = "abcdefghijklmnopqrstuvwxyz"
		return cata {
			switch $0 {
			case .Unit:
				return "()"
			case .UnitType:
				return "Unit"

			case let .Type(n) where n == 0:
				return "Type"
			case let .Type(n):
				let subscripts = "₀₁₂₃₄₅₆₇₈₉"
				return "Type" + renderNumerals(n, subscripts)

			case let .Variable(name):
				return name.analysis(
					ifGlobal: id,
					ifLocal: { renderNumerals($0, alphabet) })

			case let .Application(a, b):
				return "(\(a) \(b))"

			case let .Lambda(variable, type, body):
				return variable < 0
					? "\(type) → \(body)"
					: "λ \(renderNumerals(variable, alphabet)) : \(type) . \(body)"

			case let .Projection(term, branch):
				return "\(term).\(branch ? 1 : 0)"

			case let .Product(a, b):
				return "(\(a) × \(b))"

			case .BooleanType:
				return "Boolean"
			case let .Boolean(b):
				return String(b)

			case let .If(condition, then, `else`):
				return "if \(condition) then \(then) else \(`else`)"

			case let .Annotation(term, type):
				return "(\(term) : \(type))"
			}
		} (self)
	}
}

private func atModular<C: CollectionType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	return collection[collection.startIndex.advancedBy(offset % collection.startIndex.distanceTo(collection.endIndex), limit: collection.endIndex)]
}


import Prelude
