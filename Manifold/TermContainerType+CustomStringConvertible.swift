//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	public var description: String {
		func wrap(string: String, _ needsParentheses: Bool) -> String {
			return needsParentheses
				? "(\(string))"
				: string
		}
		let (out, _): (String, Bool) = para {
			switch $0 {
			case let .Identity(.Type(n)) where n == 0:
				return ("Type", false)
			case let .Identity(.Type(n)):
				return ("Type" + renderNumerals(n, "₀₁₂₃₄₅₆₇₈₉"), false)

			case let .Variable(name):
				return (String(name), false)

			case let .Identity(.Application((_, (a, _)), (_, b))):
				return ("\(a) \(wrap(b))", true)

			case let .Identity(.Lambda((t, type), (b, (body, _)))):
				guard let (name, _) = b.scope else { return ("\(wrap(type)) → \(body)", true) }

				if case .Identity(.Implicit) = t.out {
					return ("λ \(name) . \(body)", true)
				}
				return ("λ \(name) : \(type.0) . \(body)", true)

			case let .Identity(.Embedded(value, _, (_, (type, _)))):
				return ("'\(value)' : \(type)", true)

			case .Identity(.Implicit):
				return ("_", false)

			case let .Abstraction(name, (_, scope)):
				return ("\(name) : \(wrap(scope))", true)
			}
		}
		return out
	}
}

func renderNumerals(n: Int, _ alphabet: String) -> String {
	func atModular<C: CollectionType where C.Index: BidirectionalIndexType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
		let max = collection.startIndex.distanceTo(collection.endIndex)
		return collection[(offset >= 0 ? collection.startIndex : collection.endIndex).advancedBy(offset % max, limit: offset >= 0 ? collection.endIndex : collection.startIndex)]
	}
	return n.digits(alphabet.characters.count).lazy.map { String(atModular(alphabet.characters, offset: $0)) }.joinWithSeparator("")
}
