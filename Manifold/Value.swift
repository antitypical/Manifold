//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifPi: (Value, Value -> Value) -> T,
		@noescape ifSigma: (Value, Value -> Value) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Pi(type, body):
			return ifPi(type.value, body)
		case let .Sigma(type, body):
			return ifSigma(type.value, body)
		}
	}


	// MARK: Cases

	case Kind
	case Type
	case Pi(Box<Value>, Value -> Value)
	case Sigma(Box<Value>, Value -> Value)
}


import Box
