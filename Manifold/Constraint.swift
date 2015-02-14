//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint: Hashable {
	public init(equality t1: Type, _ t2: Type) {
		self = Equality(t1, t2)
	}


	case Equality(Type, Type)


	public var activeVariables: Set<Variable> {
		return analysis(ifEquality: { $0.freeVariables.union($1.freeVariables ) })
	}


	public func analysis<T>(#ifEquality: (Type, Type) -> T) -> T {
		switch self {
		case let Equality(t1, t2):
			return ifEquality(t1, t2)
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		switch self {
		case let Equality(t1, t2):
			return t1.hashValue ^ t2.hashValue
		}
	}
}

public func == (left: Constraint, right: Constraint) -> Bool {
	switch (left, right) {
	case let (.Equality(x1, y1), .Equality(x2, y2)):
		return x1 == x2 && y1 == y2

	default:
		return false
	}
}

public func === (left: Type, right: Type) -> Constraint {
	return Constraint(equality: left, right)
}


// MARK: - ConstraintSet

public typealias ConstraintSet = Multiset<Constraint>

func typeGraph(constraints: ConstraintSet) -> DisjointSet<Type> {
	let types = lazy(constraints)
		.flatMap {
			$0.analysis(ifEquality: {
				$0.instantiate().distinctTypes.union($1.instantiate().distinctTypes)
			})
		}
	return DisjointSet(types)
}


// MARK: - Imports

import Set
