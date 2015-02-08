//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution {
	public init(elements: [Variable: Type]) {
		self.elements = elements
	}


	public var variables: Set<Variable> {
		return Set(elements.keys)
	}


	// MARK: Private

	private let elements: [Variable: Type]
}


// MARK: - Imports

import Set
