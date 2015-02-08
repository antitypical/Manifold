//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment: DictionaryLiteralConvertible {
	public var freeVariables: Set<Variable> {
		return reduce(lazy(bindings.values).map { $0.freeVariables }, [], +)
	}


	// MARK: DictionaryLiteralConvertible
	public init(dictionaryLiteral elements: (Int, Scheme)...) {
		self.bindings = [:] + elements
	}


	private let bindings: [Int: Scheme]
}


// MARK: - Imports

import Set
