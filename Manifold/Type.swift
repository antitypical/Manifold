//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type: Hashable {
	public init(_ variable: Manifold.Variable) {
		self = Variable(variable)
	}

	public init(function t1: Type, _ t2: Type) {
		self = Function(Box(t1), Box(t2))
	}


	case Variable(Manifold.Variable)
	case Function(Box<Type>, Box<Type>)


	public var freeVariables: Set<Manifold.Variable> {
		return analysis({ [ $0 ] }, { $0.freeVariables.union($1.freeVariables) })
	}


	public func analysis<T>(ifVariable: Manifold.Variable -> T, _ ifFunction: (Type, Type) -> T) -> T {
		switch self {
		case let Variable(v):
			return ifVariable(v)

		case let Function(t1, t2):
			return ifFunction(t1.value, t2.value)
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(
			{ $0.hashValue },
			{ $0.hashValue ^ $1.hashValue }
		)
	}
}


/// Equality defined up to renaming.
public func == (left: Type, right: Type) -> Bool {
	switch (left, right) {
	case (.Variable, .Variable):
		return true

	case let (.Function(x1, x2), .Function(y1, y2)):
		return x1.value == y1.value && x2.value == y2.value

	default:
		return false
	}
}


infix operator --> {
	associativity right
}

public func --> (left: Type, right: Type) -> Type {
	return Type(function: left, right)
}


// MARK: - Imports

import Box
import Set
