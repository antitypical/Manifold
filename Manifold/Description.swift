//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Description<Index> {
	public static func end(index: Index) -> Description {
		return .End(Box(index))
	}

	case End(Box<Index>)
}


import Box
