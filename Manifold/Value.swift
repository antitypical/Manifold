//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value {
	case Kind
	case Type
	case Pi(Box<Value>, Value -> Value)
	case Sigma(Box<Value>, Value -> Value)
}


import Box
