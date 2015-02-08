//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment: DictionaryLiteralConvertible {
	// MARK: DictionaryLiteralConvertible
	public init(dictionaryLiteral elements: (Int, Scheme)...) {
		self.bindings = [:] + elements
	}

	private let bindings: [Int: Scheme]
}
