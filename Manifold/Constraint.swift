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

private func unify(t1: Type, t2: Type) -> Either<Error, Type> {
	let constructed: Either<Error, Type>? = (t1.constructed &&& t2.constructed).map { (c1, c2) -> Either<Error, Type> in
		if c1.isUnit && c2.isUnit { return .right(t1) }
		if c2.isBool && c2.isBool { return .right(t1) }
		return (c1.function &&& c2.function).map { (unify($0.0, $1.0) &&& unify($0.1, $1.1)).map { Type(function: $0, $1) } } ?? .left("mutually exclusive types: \(t1), \(t2)")
	}

	let variable: Either<Error, Type>? = (t1.variable ||| t2.variable)?.either(id, id).map(const(.right(t2)))
	return variable ?? constructed ?? .left("don’t know how to unify \(t1) with \(t2)")
}


public func checkForInfiniteTypes(graph: DisjointSet<Type>) -> Either<Error, DisjointSet<Type>> {
	return .right(graph)
}


public func checkForContradictoryTypes(partition: [Type]) -> Either<Error, Type> {
	let constructors: Set<Type> = Set(lazy(partition).filter { $0.constructed != nil })
	let unified: Either<Error, Type> = reduce(constructors, Either<Error, Type>.right(Type(Variable()))) { (into, each: Type) -> Either<Error, Type> in
		into >>- { unify($0, each) }
	}
	return unified
}

public func checkForContradictoryTypes(graph: DisjointSet<Type>) -> Either<Error, DisjointSet<Type>> {
	return reduce(graph.partitions, .right(graph)) { graph, partition in
		checkForContradictoryTypes(partition) >>- const(graph)
	}
}


public func solve(constraints: ConstraintSet) -> Either<Error, DisjointSet<Type>> {
	let (equivalences, indexByType) = typeGraph(constraints)
	let graph = reduce(constraints, equivalences) { graph, constraint in
		constraint.analysis(
			ifEquality: { t1, t2 in
				structural(t1, t2, graph) { graph, t1, t2 in
					(indexByType[t1] &&& indexByType[t2]).map { graph.union($0, $1) } ?? graph
				}
			})
	}

	return (checkForContradictoryTypes(graph) &&& checkForInfiniteTypes(graph)) >>- const(.right(graph))
}


// MARK: - Imports

import DisjointSet
import Either
import Prelude
import Set
