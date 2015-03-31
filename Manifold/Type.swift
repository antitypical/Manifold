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
		return constructed(.Function(Box(x), Box(y)))
	}

	public static func sum(x: T, _ y: T) -> Type {
		return constructed(.Sum(Box(x), Box(y)))
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
			ifUnit: const(nil),
			ifConstructed: const(nil),
			ifUniversal: const(nil))
	}

	public var isUnit: Bool {
		return analysis(
			ifVariable: const(false),
			ifUnit:  const(true),
			ifConstructed:  const(false),
			ifUniversal:  const(false))
	}

	public var constructed: Constructor<T>? {
		return analysis(
			ifVariable: const(nil),
			ifUnit: const(nil),
			ifConstructed: unit,
			ifUniversal: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, T)? {
		return analysis(
			ifVariable: const(nil),
			ifUnit: const(nil),
			ifConstructed: const(nil),
			ifUniversal: unit)
	}


	// MARK: Cases

	case Variable(Manifold.Variable)
	case Unit
	case Constructed(Box<Constructor<T>>)
	case Universal(Set<Manifold.Variable>, Box<T>)


	// MARK: Case analysis

	/// Exhaustive analysis specifying zero or more cases and a default case.
	public func analysis<Result>(ifVariable: (Manifold.Variable -> Result)? = nil, ifUnit: (() -> Result)? = nil, ifConstructed: (Constructor<T> -> Result)? = nil, ifUniversal: ((Set<Manifold.Variable>, T) -> Result)? = nil, otherwise: () -> Result) -> Result {
		switch self {
		case let .Variable(v):
			return ifVariable?(v) ?? otherwise()

		case .Unit:
			return ifUnit?() ?? otherwise()

		case let .Constructed(c):
			return ifConstructed?(c.value) ?? otherwise()

		case let .Universal(a, t):
			return ifUniversal?(a, t.value) ?? otherwise()
		}
	}

	/// Exhaustive analysis specifying all cases.
	public func analysis<Result>(@noescape #ifVariable: Manifold.Variable -> Result, @noescape ifUnit: () -> Result, @noescape ifConstructed: Constructor<T> -> Result, @noescape ifUniversal: (Set<Manifold.Variable>, T) -> Result) -> Result {
		switch self {
		case let .Variable(v):
			return ifVariable(v)

		case .Unit:
			return ifUnit()

		case let .Constructed(c):
			return ifConstructed(c.value)

		case let .Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}


	// MARK: Higher-order

	public func map<U>(transform: T -> U) -> Type<U> {
		return analysis(
			ifVariable: { .Variable($0) },
			ifUnit: { .Unit },
			ifConstructed: { .Constructed(Box($0.map(transform))) },
			ifUniversal: { .Universal($0, Box(transform($1))) })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifVariable: { "τ\($0.value)" },
			ifUnit: const("Unit"),
			ifConstructed: { $0.description },
			ifUniversal: { "∀\($0).\($1)" })
	}
}


public func == <T: Equatable> (left: Type<T>, right: Type<T>) -> Bool {
	let unit: Bool = left.isUnit && right.isUnit
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let constructed: Bool? = (left.constructed &&& right.constructed).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return unit || variable ?? constructed ?? universal ?? false
}


// MARK: - Imports

import Box
import Prelude
import Set
