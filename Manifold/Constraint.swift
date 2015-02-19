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
			ifEquality: id)
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

private func typeGraph(constraints: ConstraintSet) -> (DisjointSet<Type>, [Type: Int]) {
	let distinctTypes = Set(lazy(constraints)
		.flatMap {
			$0.analysis(ifEquality: {
				$0.instantiate().distinctTypes.union($1.instantiate().distinctTypes)
			})
		})
	let typeGraph = DisjointSet(distinctTypes)
	return (typeGraph, Dictionary(lazy(enumerate(typeGraph)).map { ($1, $0) }))
}

private func structural<T>(t1: Type, t2: Type, initial: T, f: (T, Type, Type) -> T) -> T {
	return
		(t1.function &&& t2.function).map {
			structural($0.0, $1.0, structural($0.1, $1.1, f(initial, t1, t2), f), f)
		}
	??	f(initial, t1, t2)
}

public func solve(constraints: ConstraintSet) -> Either<Error, DisjointSet<Type>> {
	let (equivalences, indexByType) = typeGraph(constraints)
	let graph = reduce(constraints, equivalences) { equivalences, constraint in
		constraint.analysis(
			ifEquality: { t1, t2 in
				structural(t1, t2, equivalences) { equivalences, t1, t2 in
					(indexByType[t1] &&& indexByType[t2]).map { equivalences.union($0, $1) } ?? equivalences
				}
			})
	}
	return reduce(graph.partitions, .right(graph)) { graph, partition in
		let constructors = reduce(lazy(partition)
			.map { $0.constructed }, Set()) {
			$0.union($1.map { [ $0 ] } ?? [])
		}
		let description = ", ".join(lazy(lazy(constructors).map(toString) |> sorted))
		return constructors.count <= 1 ?
			graph
		:	.left("mutually exclusive types: \(description)")
	}
}


// MARK: - Imports

import DisjointSet
import Either
import Prelude
import Set
