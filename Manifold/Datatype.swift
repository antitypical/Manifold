//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Datatype: DictionaryLiteralConvertible {
	public init(constructors: [(String, Telescope)]) {
		self.constructors = constructors
	}

	public init(dictionaryLiteral: (String, Telescope)...) {
		self.init(constructors: dictionaryLiteral)
	}

	public let constructors: [(String, Telescope)]

	public func value(recur: Term) -> Term {
		return value(recur, constructors: constructors[constructors.indices])
	}

	private func value<C: CollectionType where C.SubSequence == C, C.Generator.Element == (String, Telescope)>(recur: Term, constructors: C, transform: Term -> Term = id) -> Term {
		switch constructors.count {
		case 0:
			return .UnitType
		case 1:
			return constructors.first!.1.constructedType(recur)
		default:
			return Term.lambda(Term.BooleanType, {
				.If($0,
					constructors.first!.1.constructedType(recur),
					self.value(recur, constructors: constructors.dropFirst(), transform: { $0 } >>> transform))
			})
		}
	}
}


import Prelude
