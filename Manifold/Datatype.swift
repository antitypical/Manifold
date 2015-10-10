//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Datatype<Recur: TermType>: DictionaryLiteralConvertible {
	public init(constructors: [(String, Telescope<Recur>)]) {
		self.constructors = constructors
	}

	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self.init(constructors: dictionaryLiteral)
	}

	public let constructors: [(String, Telescope<Recur>)]


	public func definitions(recur: Recur) -> [Declaration<Recur>.DefinitionType] {
		return []
	}


	public func value(recur: Recur) -> Recur {
		return value(recur, constructors: constructors[constructors.indices])
	}

	private func value<C: CollectionType where C.SubSequence == C, C.Generator.Element == (String, Telescope<Recur>)>(recur: Recur, constructors: C, transform: Recur -> Recur = id) -> Recur {
		switch constructors.count {
		case 0:
			return .UnitType
		case 1:
			return constructors.first!.1.constructedType(recur)
		default:
			return Recur.lambda(Recur.BooleanType, {
				.If($0,
					constructors.first!.1.constructedType(recur),
					self.value(recur, constructors: constructors.dropFirst(), transform: { $0 } >>> transform))
			})
		}
	}
}


import Prelude
