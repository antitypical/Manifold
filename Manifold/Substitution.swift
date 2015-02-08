//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution {
	public init(elements: [Variable: Type]) {
		self.elements = elements
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


	// MARK: Private

	private let elements: [Variable: Type]
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
