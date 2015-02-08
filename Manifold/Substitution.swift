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


	// MARK: Private

	private let elements: [Variable: Type]
}


// MARK: - Imports

import Set
