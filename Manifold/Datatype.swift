//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Datatype: DictionaryLiteralConvertible {
	public init(constructors: [(String, Telescope)]) {
		self.constructors = constructors
	}

	public init(dictionaryLiteral: (String, Telescope)...) {
		self.init(constructors: dictionaryLiteral)
	}

	public let constructors: [(String, Telescope)]
}
