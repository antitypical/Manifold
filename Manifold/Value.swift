//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value {
	// MARK: Application

	public func apply(other: Value) -> Value? {
		return analysis(
			ifPi: { _, f in f(other) },
			ifSigma: { _, f in f(other) },
			otherwise: const(nil))
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifPi: (Value, Value -> Value?) -> T,
		@noescape ifSigma: (Value, Value -> Value?) -> T) -> T {
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

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifPi: ((Value, Value -> Value?) -> T)? = nil,
		ifSigma: ((Value, Value -> Value?) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifKind: { ifKind?() ?? otherwise() },
			ifType: { ifType?() ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() })
	}


	// MARK: Cases

	case Kind
	case Type
	case Pi(Box<Value>, Value -> Value?)
	case Sigma(Box<Value>, Value -> Value?)
}


import Box
import Either
import Prelude
