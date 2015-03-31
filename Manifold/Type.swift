//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type<T>: Printable {
	// MARK: Constructors

	public static func variable(variable: Manifold.Variable) -> Type {
		return .Variable(variable)
	}

	public static func constructed(constructor: Constructor<T>) -> Type {
		return .Constructed(Box(constructor))
	}

	public static func function(x: T, _ y: T) -> Type {
		return .Function(Box(x), Box(y))
	}

	public static func sum(x: T, _ y: T) -> Type {
		return .Sum(Box(x), Box(y))
	}

	public static func product(x: T, _ y: T) -> Type {
		return constructed(.Product(Box(x), Box(y)))
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

	public var isUnit: Bool {
		return analysis(
			ifUnit:  const(true),
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

	public var constructed: Constructor<T>? {
		return analysis(
			ifConstructed: unit,
			otherwise: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, T)? {
		return analysis(
			ifUniversal: unit,
			otherwise: const(nil))
	}


	// MARK: Cases

	case Variable(Manifold.Variable)
	case Unit
	case Function(Box<T>, Box<T>)
	case Sum(Box<T>, Box<T>)
	case Constructed(Box<Constructor<T>>)
	case Universal(Set<Manifold.Variable>, Box<T>)


	// MARK: Case analysis

	/// Exhaustive analysis specifying zero or more cases and a default case.
	public func analysis<Result>(ifVariable: (Manifold.Variable -> Result)? = nil, ifUnit: (() -> Result)? = nil, ifFunction: ((T, T) -> Result)? = nil, ifSum: ((T, T) -> Result)? = nil, ifProduct: ((T, T) -> Result)? = nil, ifConstructed: (Constructor<T> -> Result)? = nil, ifUniversal: ((Set<Manifold.Variable>, T) -> Result)? = nil, otherwise: () -> Result) -> Result {
		switch self {
		case let .Variable(v):
			return ifVariable?(v) ?? otherwise()

		case .Unit:
			return ifUnit?() ?? otherwise()

		case let .Function(t1, t2):
			return ifFunction?(t1.value, t2.value) ?? otherwise()

		case let .Sum(t1, t2):
			return ifSum?(t1.value, t2.value) ?? otherwise()

		case let .Constructed(c) where c.value.product != nil:
			return ifProduct.map { c.value.product! |> $0 } ?? otherwise()

		case let .Constructed(c):
			return ifConstructed?(c.value) ?? otherwise()

		case let .Universal(a, t):
			return ifUniversal?(a, t.value) ?? otherwise()
		}
	}

	/// Exhaustive analysis specifying all cases.
	public func analysis<Result>(@noescape #ifVariable: Manifold.Variable -> Result, @noescape ifUnit: () -> Result, @noescape ifFunction: (T, T) -> Result, @noescape ifSum: (T, T) -> Result, @noescape ifProduct: (T, T) -> Result, @noescape ifConstructed: Constructor<T> -> Result, @noescape ifUniversal: (Set<Manifold.Variable>, T) -> Result) -> Result {
		switch self {
		case let .Variable(v):
			return ifVariable(v)

		case .Unit:
			return ifUnit()

		case let .Function(t1, t2):
			return ifFunction(t1.value, t2.value)

		case let .Sum(t1, t2):
			return ifSum(t1.value, t2.value)

		case let .Constructed(c) where c.value.product != nil:
			return c.value.product! |> ifProduct

		case let .Constructed(c):
			return ifConstructed(c.value)

		case let .Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}


	// MARK: Higher-order

	public func map<U>(transform: T -> U) -> Type<U> {
		let binary: (T, T) -> (U, U) = { (transform($0), transform($1)) }
		return analysis(
			ifVariable: { .Variable($0) },
			ifUnit: { .Unit },
			ifFunction: binary >>> Type<U>.function,
			ifSum: binary >>> Type<U>.sum,
			ifProduct: binary >>> Type<U>.product,
			ifConstructed: { .Constructed(Box($0.map(transform))) },
			ifUniversal: { .Universal($0, Box(transform($1))) })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifVariable: { "τ\($0.value)" },
			ifUnit: const("Unit"),
			ifFunction: { "(\($0)) → \($1)" },
			ifSum: { "\($0) | \($1)" },
			ifProduct: { "(\($0), \($1))" },
			ifConstructed: { $0.description },
			ifUniversal: { "∀\($0).\($1)" })
	}
}


public func == <T: Equatable> (left: Type<T>, right: Type<T>) -> Bool {
	let unit: Bool = left.isUnit && right.isUnit
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let function: Bool? = (left.function &&& right.function).map(==)
	let sum: Bool? = (left.sum &&& right.sum).map(==)
	let product: Bool? = (left.product &&& right.product).map(==)
	let constructed: Bool? = (left.constructed &&& right.constructed).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return unit || variable ?? function ?? sum ?? product ?? constructed ?? universal ?? false
}


// MARK: - Imports

import Box
import Prelude
import Set
