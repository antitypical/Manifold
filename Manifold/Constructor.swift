//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constructor: Hashable, Printable {
	case Unit
	case Function(Type, Type)
	case Sum(Type, Type)


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

	public var function: (Type, Type)? {
		return analysis(
			ifUnit: nil,
			ifFunction: unit,
			ifSum: const(nil))
	}

	public var sum: (Type, Type)? {
		return analysis(
			ifUnit: nil,
			ifFunction: const(nil),
			ifSum: unit)
	}


	// MARK: Recursive properties

	public var freeVariables: Set<Manifold.Variable> {
		return reduce([]) { $0.union($1.freeVariables) }
	}

	public var distinctTypes: Set<Type> {
		return reduce([]) { $0.union($1.distinctTypes) }
	}


	// MARK: Case analysis

	public func analysis<T>(@autoclosure #ifUnit: () -> T, @noescape ifFunction: (Type, Type) -> T, @noescape ifSum: (Type, Type) -> T) -> T {
		switch self {
		case Unit:
			return ifUnit()
		case let Function(t1, t2):
			return ifFunction(t1, t2)
		case let Sum(t1, t2):
			return ifSum(t1, t2)
		}
	}

	public func reduce<Result>(initial: Result, @noescape _ combine: (Result, Type) -> Result) -> Result {
		return analysis(
			ifUnit: initial,
			ifFunction: { combine(combine(initial, $0), $1) },
			ifSum: { combine(combine(initial, $0), $1) })
	}


	// MARK: Hashable

	public var hashValue: Int {
		let hash: Int -> (Type, Type) -> Int = { n in { n ^ $0.hashValue ^ $1.hashValue } }
		return analysis(
			ifUnit: 0,
			ifFunction: hash(1),
			ifSum: hash(2))
	}


	// MARK: Printable

	public var description: String {
		return describe()
	}

	internal func describe(_ boundVariables: Set<Manifold.Variable> = []) -> String {
		return analysis(
			ifUnit: "Unit",
			ifFunction: { t1, t2 in
				let parameter = t1.describe(boundVariables) |> { (t1.quantifiedType?.function ?? t1.function).map(const("(\($0))")) ?? $0 }
				return "\(parameter) → \(t2.describe(boundVariables))"
			},
			ifSum: { "\($0) | \($1)" })
	}
}


public func == <T: Equatable, U: Equatable> (left: (T, U), right: (T, U)) -> Bool {
	return left.0 == right.0 && left.1 == right.1
}

public func == (left: Constructor, right: Constructor) -> Bool {
	return
		(left.isUnit && right.isUnit)
	||	(left.isBool && right.isBool)
	||	((left.function &&& right.function).map(==) ?? false)
}


// MARK: - Imports

import Prelude
