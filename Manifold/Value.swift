//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value {
	// MARK: Construction

	static func pi(value: Value, _ f: Value -> Value) -> Value {
		return .Pi(Box(value), f >>> unit)
	}

	static func sigma(value: Value, _ f: Value -> Value) -> Value {
		return .Sigma(Box(value), f >>> unit)
	}


	// MARK: Application

	public func apply(other: Value) -> Value? {
		return analysis(
			ifPi: { _, f in f(other) },
			ifSigma: { _, f in f(other) },
			otherwise: const(nil))
	}


	public func quote(_ n: Int = 0) -> Term {
		return analysis(
			ifKind: const(.kind),
			ifType: const(.type),
			ifQuote: { Term(.Variable(n - $0 - 1)) },
			ifPi: { type, f in Term(.Pi(n, Box(type.quote(n)), Box(f(.Quote(n))!.quote(n + 1)))) },
			ifSigma: { type, f in Term(.Sigma(n, Box(type.quote(n)), Box(f(.Quote(n))!.quote(n + 1)))) })
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifQuote: Int -> T,
		@noescape ifPi: (Value, Value -> Value?) -> T,
		@noescape ifSigma: (Value, Value -> Value?) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Quote(n):
			return ifQuote(n)
		case let .Pi(type, body):
			return ifPi(type.value, body)
		case let .Sigma(type, body):
			return ifSigma(type.value, body)
		}
	}

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifQuote: (Int -> T)? = nil,
		ifPi: ((Value, Value -> Value?) -> T)? = nil,
		ifSigma: ((Value, Value -> Value?) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifKind: { ifKind?() ?? otherwise() },
			ifType: { ifType?() ?? otherwise() },
			ifQuote: { ifQuote?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() })
	}


	// MARK: Cases

	case Kind
	case Type
	case Quote(Int)
	case Pi(Box<Value>, Value -> Value?)
	case Sigma(Box<Value>, Value -> Value?)
}


import Box
import Either
import Prelude
