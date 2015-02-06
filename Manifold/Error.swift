//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Error {
	case Leaf(String)
	case Branch([Error])
}
