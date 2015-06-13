//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// `Value` represents a form which cannot undergo further evaluation.
///
/// This makes it sort of like a `Term` in normal form, i.e. already evaluated.
public enum Value: CustomDebugStringConvertible {
	// MARK: Constructors

	public static func pi(value: Value, _ f: Value -> Value) -> Value {
		return .Pi(Box(value), f)
	}

	public static func sigma(value: Value, _ f: Value -> Value) -> Value {
		return .Sigma(Box(value), f)
	}

	public static func forall(f: Value -> Value) -> Value {
		return .pi(.type, f)
	}

	public static func function(from: Value, _ to: Value) -> Value {
		return .pi(from, const(to))
	}

	public static func product(a: Value, _ b: Value) -> Value {
		return .sigma(a, const(b))
	}

	public static func product(types: [Value]) -> Value {
		return foldr(types, Value.UnitValue, Value.product)
	}

	public static var type: Value {
		return .Type(0)
	}

	public static func type(n: Int) -> Value {
		return .Type(n)
	}

	public static func free(name: Name) -> Value {
		return .Free(name)
	}

	public static func boolean(b: Bool) -> Value {
		return .BooleanValue(b)
	}


	// MARK: Destructors

	public var isUnitValue: Bool {
		return analysis(
			ifUnitValue: const(true),
			otherwise: const(false))
	}

	public var isUnitType: Bool {
		return analysis(
			ifUnitType: const(true),
			otherwise: const(false))
	}

	public var isType: Bool {
		return analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var pi: (Value, Value -> Value)? {
		return analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (Value, Value -> Value)? {
		return analysis(
			ifSigma: unit,
			otherwise: const(nil))
	}


	// MARK: Application

	public func apply(other: Value) -> Value {
		return analysis(
			ifPi: { _, f in f(other) },
			otherwise: { assert(false, "illegal application of \(self) to \(other)") ; return .UnitValue })
	}


	// MARK: Projection

	public func project(second: Bool) -> Value {
		return analysis(
			ifSigma: { a, f in second ? f(a) : a },
			otherwise: { assert(false, "illegal projection: \(self).\(second ? 1 : 0)") ; return .UnitValue })
	}


	// MARK: Quotation

	public var quote: Term {
		return quote(0)
	}

	func quote(n: Int) -> Term {
		return analysis(
			ifUnitValue: const(.unitTerm),
			ifUnitType: const(.unitType),
			ifType: Term.type,
			ifPi: { type, f in
				Term.pi(type.quote(n), f(.free(.Quote(n))).quote(n + 1))
			},
			ifSigma: { type, f in
				Term.sigma(type.quote(n), f(.free(.Quote(n))).quote(n + 1))
			},
			ifFree: { name -> Term in
				name.analysis(
					ifGlobal: const(Term.free(name)),
					ifLocal: const(Term.free(name)),
					ifQuote: { Term.bound(n - $0 - 1) })
			},
			ifBooleanType: const(.booleanType),
			ifBooleanValue: Term.boolean)
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnitValue ifUnitValue: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifPi: (Value, Value -> Value) -> T,
		@noescape ifSigma: (Value, Value -> Value) -> T,
		@noescape ifFree: Name -> T,
		@noescape ifBooleanType: () -> T,
		@noescape ifBooleanValue: Bool -> T) -> T {
		switch self {
		case .UnitValue:
			return ifUnitValue()
		case .UnitType:
			return ifUnitType()
		case let .Type(n):
			return ifType(n)
		case let .Pi(type, body):
			return ifPi(type.value, body)
		case let .Sigma(type, body):
			return ifSigma(type.value, body)
		case let .Free(n):
			return ifFree(n)
		case .BooleanType:
			return ifBooleanType()
		case let .BooleanValue(b):
			return ifBooleanValue(b)
		}
	}

	public func analysis<T>(
		ifUnitValue ifUnitValue: (() -> T)? = nil,
		ifUnitType: (() -> T)? = nil,
		ifType: (Int -> T)? = nil,
		ifPi: ((Value, Value -> Value) -> T)? = nil,
		ifSigma: ((Value, Value -> Value) -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifBooleanType: (() -> T)? = nil,
		ifBooleanValue: (Bool -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifUnitValue: { ifUnitValue?() ?? otherwise() },
			ifUnitType: { ifUnitType?() ?? otherwise() },
			ifType: { ifType?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() },
			ifFree: { ifFree?($0) ?? otherwise() },
			ifBooleanType: { ifBooleanType?() ?? otherwise() },
			ifBooleanValue: { ifBooleanValue?($0) ?? otherwise() })
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return String(reflecting: quote)
	}


	// MARK: Cases

	case UnitType
	case UnitValue
	case Type(Int)
	case Pi(Box<Value>, Value -> Value)
	case Sigma(Box<Value>, Value -> Value)
	case Free(Name)
	case BooleanType
	case BooleanValue(Bool)
}


private func foldr<S: SequenceType, T>(sequence: S, _ final: T, _ combine: (S.Generator.Element, T) -> T) -> T {
	return foldr(sequence.generate(), final, combine)
}

private func foldr<G: GeneratorType, T>(var generator: G, _ final: T, _ combine: (G.Element, T) -> T) -> T {
	let next = generator.next()
	return next.map { combine($0, foldr(generator, final, combine)) } ?? final
}


import Box
import Prelude
