//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value {
	case Variable(Int)
	case Abstraction(Int, Box<Value>)
}


// MARK: - Imports

import Box
