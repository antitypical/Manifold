//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Variable: Equatable {
	let value: Int
}


public func == (left: Variable, right: Variable) -> Bool {
	return left.value == right.value
}
