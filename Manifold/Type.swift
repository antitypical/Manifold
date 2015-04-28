//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type<T>: Printable {
	// MARK: Constructors

	public static func variable(variable: Manifold.Variable) -> Type {
		return .Variable(variable)
	}

	public static func function(x: T, _ y: T) -> Type {
		return .Function(Box(x), Box(y))
	}

	public static func sum(x: T, _ y: T) -> Type {
		return .Sum(Box(x), Box(y))
	}

	public static func product(x: T, _ y: T) -> Type {
		return .Product(Box(x), Box(y))
	}

	public static func universal(variables: Set<Manifold.Variable>, _ quantified: T) -> Type {
		return .Universal(variables, Box(quantified))
	}


	// MARK: Destructors

	public var variable: Manifold.Variable? {
		return analysis(
			ifVariable: unit,
			otherwise: const(nil))
	}

	public var isKind: Bool {
		return analysis(
			ifKind: const(true),
			otherwise: const(false))
	}

	public var isUnit: Bool {
		return analysis(
			ifUnit: const(true),
			otherwise: const(false))
	}

	public var function: (T, T)? {
		return analysis(
			ifFunction: unit,
			otherwise: const(nil))
	}

	public var sum: (T, T)? {
		return analysis(
			ifSum: unit,
			otherwise: const(nil))
	}

	public var product: (T, T)? {
		return analysis(
			ifProduct: unit,
			otherwise: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, T)? {
		return analysis(
			ifUniversal: unit,
			otherwise: const(nil))
	}


	// MARK: Cases

	case Variable(Manifold.Variable)
	case Kind
	case Unit
	case Function(Box<T>, Box<T>)
	case Sum(Box<T>, Box<T>)
	case Product(Box<T>, Box<T>)
	case Universal(Set<Manifold.Variable>, Box<T>)


	// MARK: Case analysis

	/// Exhaustive analysis specifying zero or more cases and a default case.
	public func analysis<Result>(ifVariable: (Manifold.Variable -> Result)? = nil, ifKind: (() -> Result)? = nil, ifUnit: (() -> Result)? = nil, ifFunction: ((T, T) -> Result)? = nil, ifSum: ((T, T) -> Result)? = nil, ifProduct: ((T, T) -> Result)? = nil, ifUniversal: ((Set<Manifold.Variable>, T) -> Result)? = nil, otherwise: () -> Result) -> Result {
		return analysis(
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifKind: { ifKind?() ?? otherwise() },
			ifUnit: { ifUnit?() ?? otherwise() },
			ifFunction: { ifFunction?($0) ?? otherwise() },
			ifSum: { ifSum?($0) ?? otherwise() },
			ifProduct: { ifProduct?($0) ?? otherwise() },
			ifUniversal: { ifUniversal?($0) ?? otherwise() })
	}

	/// Exhaustive analysis specifying all cases.
	public func analysis<Result>(@noescape #ifVariable: Manifold.Variable -> Result, @noescape ifKind: () -> Result, @noescape ifUnit: () -> Result, @noescape ifFunction: (T, T) -> Result, @noescape ifSum: (T, T) -> Result, @noescape ifProduct: (T, T) -> Result, @noescape ifUniversal: (Set<Manifold.Variable>, T) -> Result) -> Result {
		switch self {
		case let .Variable(v):
			return ifVariable(v)

		case Kind:
			return ifKind()

		case .Unit:
			return ifUnit()

		case let .Function(t1, t2):
			return ifFunction(t1.value, t2.value)

		case let .Sum(t1, t2):
			return ifSum(t1.value, t2.value)

		case let .Product(t1, t2):
			return ifProduct(t1.value, t2.value)

		case let .Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}


	// MARK: Higher-order

	public func map<U>(transform: T -> U) -> Type<U> {
		let binary: (T, T) -> (U, U) = { (transform($0), transform($1)) }
		return analysis(
			ifVariable: { .Variable($0) },
			ifKind: { .Kind },
			ifUnit: { .Unit },
			ifFunction: binary >>> Type<U>.function,
			ifSum: binary >>> Type<U>.sum,
			ifProduct: binary >>> Type<U>.product,
			ifUniversal: { .Universal($0, Box(transform($1))) })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifVariable: { "τ\($0.value)" },
			ifKind: const("Type"),
			ifUnit: const("Unit"),
			ifFunction: { "(\($0)) → \($1)" },
			ifSum: { "\($0) | \($1)" },
			ifProduct: { "(\($0), \($1))" },
			ifUniversal: { "∀\($0).\($1)" })
	}
}


private func == <T: Equatable, U: Equatable> (left: (T, U), right: (T, U)) -> Bool {
	return left.0 == right.0 && left.1 == right.1
}

public func == <T: Equatable> (left: Type<T>, right: Type<T>) -> Bool {
	let kind: Bool = left.isKind && right.isKind
	let unit: Bool = left.isUnit && right.isUnit
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let function: Bool? = (left.function &&& right.function).map(==)
	let sum: Bool? = (left.sum &&& right.sum).map(==)
	let product: Bool? = (left.product &&& right.product).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return kind || unit || variable ?? function ?? sum ?? product ?? universal ?? false
}


// MARK: - Imports

import Box
import Prelude
import Set
