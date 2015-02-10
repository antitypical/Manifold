//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression: Hashable {
	case Value(Manifold.Value)
	case Application(Box<Expression>, Box<Expression>)


	// MARK: Hashable

	public var hashValue: Int {
		switch self {
		case let Value(v):
			return v.hashValue

		case let Application(e1, e2):
			return e1.value.hashValue ^ e2.value.hashValue
		}
	}
}

public func == (left: Expression, right: Expression) -> Bool {
	switch (left, right) {
	case let (.Value(x), .Value(y)):
		return x == y

	case let (.Application(x1, y1), .Application(x2, y2)):
		return x1.value == x2.value && y1.value == y2.value

	default:
		return false
	}
}


// MARK: - Imports

import Box
