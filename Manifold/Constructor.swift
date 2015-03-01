//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constructor<T: Hashable>: Hashable, Printable {
	case Unit
	case Function(Box<T>, Box<T>)
	case Sum(Box<T>, Box<T>)


	// MARK: Decomposition

	public var isUnit: Swift.Bool {
		return analysis(
			ifUnit: true,
			ifFunction: const(false),
			ifSum: const(false))
	}

	public var isBool: Swift.Bool {
		return analysis(
			ifUnit: false,
			ifFunction: const(false),
			ifSum: const(false))
	}

	public var function: (T, T)? {
		return analysis(
			ifUnit: nil,
			ifFunction: unit,
			ifSum: const(nil))
	}

	public var sum: (T, T)? {
		return analysis(
			ifUnit: nil,
			ifFunction: const(nil),
			ifSum: unit)
	}


	// MARK: Case analysis

	public func analysis<Result>(@autoclosure #ifUnit: () -> Result, @noescape ifFunction: (T, T) -> Result, @noescape ifSum: (T, T) -> Result) -> Result {
		switch self {
		case Unit:
			return ifUnit()
		case let Function(t1, t2):
			return ifFunction(t1.value, t2.value)
		case let Sum(t1, t2):
			return ifSum(t1.value, t2.value)
		}
	}

	public func reduce<Result>(initial: Result, @noescape _ combine: (Result, T) -> Result) -> Result {
		return analysis(
			ifUnit: initial,
			ifFunction: { combine(combine(initial, $0), $1) },
			ifSum: { combine(combine(initial, $0), $1) })
	}


	// MARK: Hashable

	public var hashValue: Int {
		let hash: Int -> (T, T) -> Int = { n in { n ^ $0.hashValue ^ $1.hashValue } }
		return analysis(
			ifUnit: 0,
			ifFunction: hash(1),
			ifSum: hash(2))
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifUnit: "Unit",
			ifFunction: { "(\($0)) → \($1)" },
			ifSum: { "\($0) | \($1)" })
	}
}


public func == <T: Equatable, U: Equatable> (left: (T, U), right: (T, U)) -> Bool {
	return left.0 == right.0 && left.1 == right.1
}

public func == <T> (left: Constructor<T>, right: Constructor<T>) -> Bool {
	return
		(left.isUnit && right.isUnit)
	||	(left.isBool && right.isBool)
	||	((left.function &&& right.function).map(==) ?? false)
}


// MARK: - Imports

import Box
import Prelude
