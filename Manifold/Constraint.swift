//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint: Equatable {
	case Equality(Type, Type)
}

public func == (left: Constraint, right: Constraint) -> Bool {
	switch (left, right) {
	case let (.Equality(x1, y1), .Equality(x2, y2)):
		return x1 == x2 && y1 == y2

	default:
		return false
	}
}
