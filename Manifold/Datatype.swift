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
		return constructors[constructors.indices].fold((definitions: [], transform: id)) {
			($1.definitions + [ (symbol: $0.0, type: $0.1.type(recur).out, value: $1.transform($1.definitions.count > 0
				? .Product(true, $0.1.value(recur))
				: $0.1.value(recur)).out) ], $1.transform)
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
