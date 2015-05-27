//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// `Value` represents a form which cannot undergo further evaluation.
///
/// This makes it sort of like a `Term` in normal form, i.e. already evaluated.
public enum Value: DebugPrintable {
	// MARK: Constructors

	public static func pi(value: Value, _ f: Value -> Value) -> Value {
		return .Pi(Box(value), f >>> Either.right)
	}

	public static func sigma(value: Value, _ f: Value -> Value) -> Value {
		return .Sigma(Box(value), f >>> Either.right)
	}

	public static func forall(f: Value -> Value) -> Value {
		return .pi(.Type, f)
	}

	public static func function(from: Value, _ to: Value) -> Value {
		return .pi(from, const(to))
	}

	public static func application(f: Manifold.Neutral, _ v: Value) -> Value {
		return .neutral(.application(f, v))
	}

	public static func parameter(name: Name) -> Value {
		return .neutral(.Parameter(name))
	}

	public static func neutral(value: Manifold.Neutral) -> Value {
		return .Neutral(Box(value))
	}


	// MARK: Destructors

	public var isType: Bool {
		return analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var pi: (Value, Value -> Either<Error, Value>)? {
		return analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (Value, Value -> Either<Error, Value>)? {
		return analysis(
			ifSigma: unit,
			otherwise: const(nil))
	}

	public var neutral: Manifold.Neutral? {
		return analysis(
			ifNeutral: unit,
			otherwise: const(nil))
	}


	// MARK: Application

	public func apply(other: Value) -> Either<Error, Value> {
		return analysis(
			ifPi: { _, f in f(other) },
			ifSigma: { _, f in f(other) },
			ifNeutral: { .right(.neutral(.application($0, other))) },
			otherwise: const(Either.left("illegal application of \(self) to \(other)")))
	}


	// MARK: Quotation

	public var quote: Term {
		return quote(0)
	}

	func quote(n: Int) -> Term {
		return analysis(
			ifType: const(.type),
			ifPi: { type, f in
				f(.parameter(.Quote(n))).either(
					ifLeft: { x in assert(false, "\(x) in \(self)") ; return Term.type },
					ifRight: { Term(Checkable.Pi(Box(type.quote(n)), Box($0.quote(n + 1)))) })
			},
			ifSigma: { type, f in
				f(.parameter(.Quote(n))).either(
					ifLeft: { x in assert(false, "\(x) in \(self)") ; return Term.type },
					ifRight: { Term(Checkable.Sigma(Box(type.quote(n)), Box($0.quote(n + 1)))) })
			},
			ifNeutral: {
				$0.quote(n)
			})
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifType: () -> T,
		@noescape ifPi: (Value, Value -> Either<Error, Value>) -> T,
		@noescape ifSigma: (Value, Value -> Either<Error, Value>) -> T,
		@noescape ifNeutral: Manifold.Neutral -> T) -> T {
		switch self {
		case .Type:
			return ifType()
		case let .Pi(type, body):
			return ifPi(type.value, body)
		case let .Sigma(type, body):
			return ifSigma(type.value, body)
		case let .Neutral(n):
			return ifNeutral(n.value)
		}
	}

	public func analysis<T>(
		ifType: (() -> T)? = nil,
		ifPi: ((Value, Value -> Either<Error, Value>) -> T)? = nil,
		ifSigma: ((Value, Value -> Either<Error, Value>) -> T)? = nil,
		ifNeutral: (Manifold.Neutral -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifType: { ifType?() ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() },
			ifNeutral: { ifNeutral?($0) ?? otherwise() })
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifType: const("Type"),
			ifPi: { "(Π ? : \(toDebugString($0)) . \(toDebugString($1)))" },
			ifSigma: { "(Σ ? : \(toDebugString($0)) . \(toDebugString($1)))" },
			ifNeutral: toDebugString)
	}


	// MARK: Cases

	case Type
	case Pi(Box<Value>, Value -> Either<Error, Value>)
	case Sigma(Box<Value>, Value -> Either<Error, Value>)
	case Neutral(Box<Manifold.Neutral>)
}


import Box
import Either
import Prelude
