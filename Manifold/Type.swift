//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type {
	case Variable(Manifold.Variable)
	case Function(Box<Type>, Box<Type>)


	public func analysis<T>(ifVariable: Manifold.Variable -> T, _ ifFunction: (Type, Type) -> T) -> T {
		switch self {
		case let Variable(v):
			return ifVariable(v)

		case let Function(t1, t2):
			return ifFunction(t1.value, t2.value)
		}
	}
}


// MARK: - Imports

import Box
