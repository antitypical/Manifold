//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name {
	// MARK: Destructors

	public var value: Int {
		switch self {
		case let .Local(n):
			return n
		case let .Quote(n):
			return n
		}
	}
	// MARK: Cases

	case Local(Int)
	case Quote(Int)
}
