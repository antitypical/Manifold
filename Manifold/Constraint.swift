//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint: Hashable, Printable {
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


	// MARK: Decomposition

	var equality: (Type, Type)? {
		return analysis(
			ifEquality: unit)
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(
			ifEquality: { $0.hashValue ^ $1.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifEquality: { "\($0) ≡ \($1)" })
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

private func reduce<T>(t1: Type, t2: Type, initial: T, combine: (T, Type, Type) -> T) -> T {
	let recur: ((Type, Type), (Type, Type)) -> T = {
		reduce($0.0, $1.0, reduce($0.1, $1.1, combine(initial, t1, t2), combine), combine)
	}
	let function = (t1.function &&& t2.function).map(recur)
	let sum = (t1.sum &&& t2.sum).map(recur)
	return
		function
	??	sum
	??	combine(initial, t1, t2)
}


public func occurs(v: Variable, t: Type) -> Bool {
	return t.freeVariables.contains(v)
}

private func unify(c1: Type.Constructor, c2: Type.Constructor) -> Either<Error, Substitution>? {
	let identity: Either<Error, Substitution> = .right([:])
	if c1.isUnit && c2.isUnit { return identity }
	if c1.isBool && c2.isBool { return identity }
	let recur: ((Type, Type), (Type, Type)) -> Either<Error, Substitution> = { (unify($0.0, $1.0) &&& unify($0.1, $1.1)).map(uncurry(Substitution.compose)) }
	let function = (c1.function &&& c2.function).map(recur)
	let sum = (c1.sum &&& c2.sum).map(recur)
	return
		function
	??	sum
}

public func unify(t1: Type, t2: Type) -> Either<Error, Substitution> {
	let constructed: Either<Error, Substitution>? =
		(t1.constructed &&& t2.constructed).map(unify)
	??	.left("mutually exclusive types: \(t1), \(t2)")

	let infinite: Either<Error, Substitution> = .left("{\(t1), \(t2)} form an infinite type")
	let v1 = t1.variable.map { occurs($0, t2) ? infinite : .right([$0: t2]) }
	let v2 = t2.variable.map { occurs($0, t1) ? infinite : .right([$0: t1]) }

	return
		v1
	??	v2
	??	constructed
	??	.left("don’t know how to unify \(t1) with \(t2)")
}


public func checkForInconsistencies(partition: [Type]) -> (Error?, Substitution) {
	typealias Result = (Error?, Substitution, Type)
	let initial: Result = (nil, [:], Type(Variable()))
	let result: Result = reduce(partition, initial) { into, each in
		unify(into.2, each).either({ error in (into.0.map { $0 + error } ?? error, into.1, each) }, { (into.0, into.1.compose($0), each) })
	}
	return (result.0, result.1)
}

public func solve(constraints: ConstraintSet) -> Either<Error, Substitution> {
	func findOrAdd(type: Type, inout equivalences: DisjointSet<Type>, inout indices: [Type: Int]) -> Int {
		if let index = indices[type] { return index }
		let index = equivalences.count
		indices[type] = index
		equivalences.append(type)
		return index
	}
	let (graph: DisjointSet<Type>, indexByType: [Type: Int]) = reduce(constraints, ([], [:])) { (pair, constraint) in
		constraint.analysis { t1, t2 in
			reduce(t1.instantiate(), t2.instantiate(), pair) { (var pair, t1, t2) in
				let i1 = findOrAdd(t1, &pair.0, &pair.1)
				let i2 = findOrAdd(t2, &pair.0, &pair.1)
				pair.0.unionInPlace(i1, i2)
				return pair
			}
		}
	}

	return reduce(graph.partitions, Either<Error, Substitution>.right([:])) { substitution, partition in
		substitution >>- { substitution in
			let result = checkForInconsistencies(partition)
			return result.0.map(Either.left) ?? .right(result.1.compose(substitution))
		}
	}
}


// MARK: - Imports

import DisjointSet
import Either
import Prelude
import Set
