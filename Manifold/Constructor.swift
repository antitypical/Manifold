//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constructor<T>: Printable {
	// MARK: Constructors

	public static func function(x: T, _ y: T) -> Constructor {
		return .Function(Box(x), Box(y))
	}

	public static func sum(x: T, _ y: T) -> Constructor {
		return .Sum(Box(x), Box(y))
	}

	public static func product(x: T, _ y: T) -> Constructor {
		return .Product(Box(x), Box(y))
	}


	case Unit
	case Function(Box<T>, Box<T>)
	case Sum(Box<T>, Box<T>)
	case Product(Box<T>, Box<T>)


	// MARK: Decomposition

	public var isUnit: Swift.Bool {
		return analysis(
			ifUnit: true,
			ifFunction: const(false),
			ifSum: const(false),
			ifProduct: const(false))
	}

	public var function: (T, T)? {
		return analysis(
			ifUnit: nil,
			ifFunction: unit,
			ifSum: const(nil),
			ifProduct: const(nil))
	}

	public var sum: (T, T)? {
		return analysis(
			ifUnit: nil,
			ifFunction: const(nil),
			ifSum: unit,
			ifProduct: const(nil))
	}

	public var product: (T, T)? {
		return analysis(
			ifUnit: nil,
			ifFunction: const(nil),
			ifSum: const(nil),
			ifProduct: unit)
	}


	// MARK: Functor

	public func map<U>(@noescape transform: T -> U) -> Constructor<U> {
		return analysis(
			ifUnit: .Unit,
			ifFunction: { .Function(Box(transform($0)), Box(transform($1))) },
			ifSum: { .Sum(Box(transform($0)), Box(transform($1))) },
			ifProduct: { .Product(Box(transform($0)), Box(transform($1))) })
	}


	// MARK: Case analysis

	public func analysis<Result>(@autoclosure #ifUnit: () -> Result, @noescape ifFunction: (T, T) -> Result, @noescape ifSum: (T, T) -> Result, @noescape ifProduct: (T, T) -> Result) -> Result {
		switch self {
		case Unit:
			return ifUnit()
		case let Function(t1, t2):
			return ifFunction(t1.value, t2.value)
		case let Sum(t1, t2):
			return ifSum(t1.value, t2.value)
		case let Product(t1, t2):
			return ifProduct(t1.value, t2.value)
		}
	}

	public func reduce<Result>(initial: Result, @noescape _ combine: (Result, T) -> Result) -> Result {
		return analysis(
			ifUnit: initial,
			ifFunction: { combine(combine(initial, $0), $1) },
			ifSum: { combine(combine(initial, $0), $1) },
			ifProduct: { combine(combine(initial, $0), $1) })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifUnit: "Unit",
			ifFunction: { "(\($0)) → \($1)" },
			ifSum: { "\($0) | \($1)" },
			ifProduct: { "(\($0), \($1))" })
	}
}


public func == <T: Equatable, U: Equatable> (left: (T, U), right: (T, U)) -> Bool {
	return left.0 == right.0 && left.1 == right.1
}

public func == <T: Equatable> (left: Constructor<T>, right: Constructor<T>) -> Bool {
	return
		(left.isUnit && right.isUnit)
	||	((left.function &&& right.function).map(==) ?? false)
	||	((left.sum &&& right.sum).map(==) ?? false)
	||	((left.product &&& right.product).map(==) ?? false)
}


// MARK: - Imports

import Box
import Prelude
