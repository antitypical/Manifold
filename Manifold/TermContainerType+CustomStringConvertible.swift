//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
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
		func wrap(string: String, _ needsParentheses: Bool) -> String {
			return needsParentheses
				? "(\(string))"
				: string
		}
		let (out, _): (String, Bool) = para {
			switch $0 {
			case .Unit:
				return ("()", false)
			case .UnitType:
				return ("Unit", false)

			case let .Type(n) where n == 0:
				return ("Type", false)
			case let .Type(n):
				return ("Type" + Self.renderNumerals(n, subscripts), false)

			case let .Variable(name):
				return (Self.describe(name), false)

			case let .Application((_, (a, _)), (_, b)):
				return ("\(a) \(wrap(b))", true)

			case let .Lambda(variable, (_, type), (b, (body, _))):
				return (b.freeVariables.contains(variable)
					? "λ \(Self.describe(.Local(variable))) : \(type.0) . \(body)"
					: "\(wrap(type)) → \(body)", true)

			case .BooleanType:
				return ("Boolean", false)
			case let .Boolean(b):
				return (String(b), false)
			}
		}
		return out
	}
}

private func atModular<C: CollectionType where C.Index: BidirectionalIndexType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	let max = collection.startIndex.distanceTo(collection.endIndex)
	return collection[(offset >= 0 ? collection.startIndex : collection.endIndex).advancedBy(offset % max, limit: offset >= 0 ? collection.endIndex : collection.startIndex)]
}


import Prelude
