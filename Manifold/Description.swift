//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Description<Index> {
	public static func end(index: Index) -> Description {
		return .End(Box(index))
	}


	var end: Index? {
		switch self {
		case let .End(index):
			return index.value
		default:
			return nil
		}
	}


	case End(Box<Index>)
}


import Box
