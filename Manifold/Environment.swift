//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment: DictionaryLiteralConvertible {
	public init(_ bindings: [Int: Type]) {
		self.typings = bindings
	}


	public var freeVariables: Set<Variable> {
		return reduce(lazy(typings.values).map { $0.freeVariables }, [], uncurry(Set.union))
	}


	public func generalize(type: Type) -> Type {
		return Type(forall: type.freeVariables.subtract(freeVariables), type)
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Int, Type)...) {
		self.init([:] + elements)
	}


	// MARK: Private

	private init<S: SequenceType where S.Generator.Element == Dictionary<Int, Type>.Element>(_ sequence: S) {
		self.init([:] + sequence)
	}

	private let typings: [Int: Type]
}


public func / (environment: Environment, variable: Int) -> Environment {
	return Environment(lazy(environment.typings).filter { y, _ in y != variable })
}


// MARK: - Imports

import Prelude
