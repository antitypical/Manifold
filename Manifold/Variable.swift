//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Variable: Hashable {
	let value: Int


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}
}


public func == (left: Variable, right: Variable) -> Bool {
	return left.value == right.value
}
