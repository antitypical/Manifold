//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution: DictionaryLiteralConvertible, Equatable {
	public init(elements: [Variable: Type]) {
		self.elements = elements
	}


	public func compose(other: Substitution) -> Substitution {
		let variables = self.variables
		return Substitution(elements: elements + other.elements)
	}

	public var variables: Set<Variable> {
		return Set(elements.keys)
	}

	public var occurringVariables: Set<Variable> {
		let replacementVariables = reduce(lazy(elements.values).map { $0.freeVariables }, Set(), +)
		return variables.intersection(replacementVariables)
	}

	public var isIdempotent: Bool {
		return occurringVariables.count == 0
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Variable, Type)...) {
		self.init(elements: [:] + elements)
	}


	// MARK: Private

	private let elements: [Variable: Type]
}


public func == (left: Substitution, right: Substitution) -> Bool {
	return left.elements == right.elements
}


private func + <T: Hashable, U, S: SequenceType where S.Generator.Element == Dictionary<T, U>.Element> (var left: Dictionary<T, U>, right: S) -> Dictionary<T, U> {
	for (key, value) in SequenceOf<(T, U)>(right) {
		if left[key] == nil {
			left[key] = value
		}
	}
	return left
}


// MARK: - Imports

import Set
