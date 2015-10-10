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
		return constructors[constructors.indices].fold((definitions: [], transform: id)) { (each: (String, Telescope<Recur>), into: (definitions: [Declaration<Recur>.DefinitionType], transform: Recur -> Recur)) in
			let value: Expression<Recur> = into.definitions.count > 0
				? Expression<Recur>.Product(true, each.1.value(recur))
				: each.1.value(recur).out
			return (into.definitions + [ (symbol: each.0, type: each.1.type(recur).out, value: value) ], into.transform)
		}.definitions
	}


	public func value(recur: Recur) -> Recur {
		return constructors[constructors.indices].fold(nil) { each, into in
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
