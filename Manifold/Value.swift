//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value: Equatable {
	case Variable(Int)
	case Abstraction(Int, Box<Value>)
}

public func == (left: Value, right: Value) -> Bool {
	switch (left, right) {
	case let (.Variable(x), .Variable(y)):
		return x == y

	case let (.Abstraction(x1, y1), .Abstraction(x2, y2)):
		return x1 == x2 && y1 == y2

	default:
		return false
	}
}


// MARK: - Imports

import Box
