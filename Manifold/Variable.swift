//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Variable: Hashable, Printable {
	let value: Int


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}


	// MARK: Printable

	public var description: String {
		return value.description
	}
}


public func == (left: Variable, right: Variable) -> Bool {
	return left.value == right.value
}
