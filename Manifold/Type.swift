//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type {
	public init(_ variable: Manifold.Variable) {
		self = Variable(variable)
	}

	public init(function t1: Type, _ t2: Type) {
		self = Function(Box(t1), Box(t2))
	}


	case Variable(Manifold.Variable)
	case Function(Box<Type>, Box<Type>)


	public var freeVariables: Set<Manifold.Variable> {
		return analysis({ [ $0 ] }, { $0.freeVariables + $1.freeVariables })
	}


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
import Set
