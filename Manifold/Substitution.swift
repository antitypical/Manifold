//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution {
	public init(elements: [Variable: Type]) {
		self.elements = elements
	}


	// MARK: Private

	private let elements: [Variable: Type]
}
