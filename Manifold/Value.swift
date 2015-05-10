//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Value: DebugPrintable {
	// MARK: Constructors

	public static func pi(value: Value, _ f: Value -> Value) -> Value {
		return .Pi(Box(value), f >>> Either.right)
	}

	public static func sigma(value: Value, _ f: Value -> Value) -> Value {
		return .Sigma(Box(value), f >>> Either.right)
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


	// MARK: Application

	public func apply(other: Value) -> Either<Error, Value> {
		return analysis(
			ifPi: { _, f in f(other) },
			ifSigma: { _, f in f(other) },
			otherwise: const(Either.left("illegal application of \(self) to \(other)")))
	}


	// MARK: Quotation

	public var quote: Term {
		return quote(0)
	}

	private func quote(n: Int) -> Term {
		return analysis(
			ifType: const(.type),
			ifFree: {
				$0.analysis(
					ifLocal: const(Term.free($0)),
					ifQuote: Term.bound)
			},
			ifPi: { type, f in
				f(.Free(.Quote(n))).either(
					ifLeft: { x in fatalError("\(toString(x)) in \(self)") ; return Term.type },
					ifRight: { Term(Expression.Pi(n, Box(type.quote(n)), Box($0.quote(n + 1)))) })
			},
			ifSigma: { type, f in
				f(.Free(.Quote(n))).either(
					ifLeft: { x in fatalError("\(toString(x)) in \(self)") ; return Term.type },
					ifRight: { Term(Expression.Sigma(n, Box(type.quote(n)), Box($0.quote(n + 1)))) })
			})
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifType: () -> T,
		@noescape ifFree: Name -> T,
		@noescape ifPi: (Value, Value -> Either<Error, Value>) -> T,
		@noescape ifSigma: (Value, Value -> Either<Error, Value>) -> T) -> T {
		switch self {
		case .Type:
			return ifType()
		case let .Free(n):
			return ifFree(n)
		case let .Pi(type, body):
			return ifPi(type.value, body)
		case let .Sigma(type, body):
			return ifSigma(type.value, body)
		}
	}

	public func analysis<T>(
		ifType: (() -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifPi: ((Value, Value -> Either<Error, Value>) -> T)? = nil,
		ifSigma: ((Value, Value -> Either<Error, Value>) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifType: { ifType?() ?? otherwise() },
			ifFree: { ifFree?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() })
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifType: const("Type"),
			ifFree: toDebugString,
			ifPi: { "(Π ? : \(toDebugString($0)) . \(toDebugString($1)))" },
			ifSigma: { "(Σ ? : \(toDebugString($0)) . \(toDebugString($1)))" })
	}


	// MARK: Cases

	case Type
	case Free(Name)
	case Pi(Box<Value>, Value -> Either<Error, Value>)
	case Sigma(Box<Value>, Value -> Either<Error, Value>)
}


import Box
import Either
import Prelude
