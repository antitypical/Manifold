//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Datatype<Recur: TermType>: DictionaryLiteralConvertible {
	public var constructors: [(String, Telescope<Recur>)]

	public init(constructors: [(String, Telescope<Recur>)]) {
		self.constructors = constructors
	}

	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self.init(constructors: dictionaryLiteral)
	}


	public func definitions(transform: Recur -> Recur = id) -> [(symbol: String, type: Recur -> Recur, value: Recur -> Recur)] {
		return []
	}
}


import Prelude
