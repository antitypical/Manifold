//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment: DictionaryLiteralConvertible {
	public init(_ bindings: [Int: Scheme]) {
		self.bindings = bindings
	}


	public var freeVariables: Set<Variable> {
		return reduce(lazy(bindings.values).map { $0.freeVariables }, [], +)
	}


	public func generalize(type: Type) -> Scheme {
		return Scheme(type.freeVariables - freeVariables, type)
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Int, Scheme)...) {
		self.init([:] + elements)
	}


	// MARK: Private

	private init<S: SequenceType where S.Generator.Element == Dictionary<Int, Scheme>.Element>(_ sequence: S) {
		self.init([:] + sequence)
	}

	private let bindings: [Int: Scheme]
}


public func / (environment: Environment, variable: Int) -> Environment {
	return Environment(lazy(environment.bindings).filter { y, _ in y != variable })
}


// MARK: - Imports

import Set
