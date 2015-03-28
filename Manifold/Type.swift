//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type<T>: Printable {
	// MARK: Constructors

	public static func variable(variable: Manifold.Variable) -> Type {
		return .Variable(variable)
	}

	public static func constructed(constructor: Constructor<T>) -> Type {
		return .Constructed(Box(constructor))
	}

	public static func universal(variables: Set<Manifold.Variable>, _ quantified: T) -> Type {
		return .Universal(variables, Box(quantified))
	}


	// MARK: Destructors

	public var variable: Manifold.Variable? {
		return analysis(
			ifVariable: unit,
			ifConstructed: const(nil),
			ifUniversal: const(nil))
	}

	public var constructed: Constructor<T>? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: unit,
			ifUniversal: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, T)? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: const(nil),
			ifUniversal: unit)
	}


	// MARK: Cases

	case Variable(Manifold.Variable)
	case Constructed(Box<Constructor<T>>)
	case Universal(Set<Manifold.Variable>, Box<T>)


	// MARK: Case analysis

	public func analysis<Result>(@noescape #ifVariable: Manifold.Variable -> Result, @noescape ifConstructed: Constructor<T> -> Result, @noescape ifUniversal: (Set<Manifold.Variable>, T) -> Result) -> Result {
		switch self {
		case let Variable(v):
			return ifVariable(v)

		case let Constructed(c):
			return ifConstructed(c.value)

		case let Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}


	// MARK: Higher-order

	public func map<U>(transform: T -> U) -> Type<U> {
		return analysis(
			ifVariable: { .Variable($0) },
			ifConstructed: { .Constructed(Box($0.map(transform))) },
			ifUniversal: { .Universal($0, Box(transform($1))) })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifVariable: { "τ\($0.value)" },
			ifConstructed: { $0.description },
			ifUniversal: { "∀\($0).\($1)" })
	}
}


public func == <T: Equatable> (left: Type<T>, right: Type<T>) -> Bool {
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let constructed: Bool? = (left.constructed &&& right.constructed).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return variable ?? constructed ?? universal ?? false
}


// MARK: - Imports

import Box
import Prelude
import Set
