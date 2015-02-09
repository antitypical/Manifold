//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value: Hashable {
	case Variable(Int)
	case Abstraction(Int, Box<Value>)


	// MARK: Hashable

	public var hashValue: Int {
		switch self {
		case let Variable(i):
			return i

		case let Abstraction(i, v):
			return i ^ v.value.hashValue
		}
	}
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
