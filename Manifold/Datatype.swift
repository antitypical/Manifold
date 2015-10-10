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
		return constructors.map {
			($0, $1.type(recur).out, $1.value(recur).out)
		}
	}


	public func value(recur: Recur) -> Recur {
		return value(recur, constructors: constructors[constructors.indices])
	}

	private func value<C: CollectionType where C.SubSequence == C, C.Generator.Element == (String, Telescope<Recur>)>(recur: Recur, constructors: C, transform: Recur -> Recur = id) -> Recur {
		return constructors.fold(nil) { each, into in
			into.map { into in
				Recur.lambda(Recur.BooleanType) {
					.If($0,
						each.1.constructedType(recur),
						into)
				}
			} ?? each.1.constructedType(recur)
		} ?? .UnitType
	}
}


import Prelude
