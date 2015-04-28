//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint: Hashable, Printable {
	public init(equality t1: Term, _ t2: Term) {
		if let (v1, v2) = (t1.variable?.value &&& t2.variable?.value) where v2 > v1 {
			self = Equality(t2, t1)
		} else {
			self = Equality(t1, t2)
		}
	}


	case Equality(Term, Term)


	public var activeVariables: Set<Variable> {
		return analysis(ifEquality: { $0.freeVariables.union($1.freeVariables ) })
	}


	public func analysis<T>(#ifEquality: (Term, Term) -> T) -> T {
		switch self {
		case let Equality(t1, t2):
			return ifEquality(t1, t2)
		}
	}


	// MARK: Decomposition

	var equality: (Term, Term)? {
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

public func === (left: Term, right: Term) -> Constraint {
	return Constraint(equality: left, right)
}


// MARK: - ConstraintSet

public typealias ConstraintSet = Multiset<Constraint>

private func reduce<T>(t1: Term, t2: Term, initial: T, combine: (T, Term, Term) -> T) -> T {
	let recur: ((Term, Term), (Term, Term)) -> T = {
		reduce($0.0, $1.0, reduce($0.1, $1.1, combine(initial, t1, t2), combine), combine)
	}
	let function = (t1.function &&& t2.function).map(recur)
	let sum = (t1.sum &&& t2.sum).map(recur)
	let product = (t1.product &&& t2.product).map(recur)
	return function ?? sum ?? product ?? combine(initial, t1, t2)
}


public func occurs(v: Variable, t: Term) -> Bool {
	return t.variable != v && t.freeVariables.contains(v)
}

public func unify(t1: Term, t2: Term) -> Either<Error, Substitution> {
	if t1.isUnit && t2.isUnit { return .right([:]) }

	let infinite: Either<Error, Substitution> = .left("{\(t1), \(t2)} form an infinite type")
	let v1 = t1.variable.map { occurs($0, t2) ? infinite : .right([$0: t2]) }
	let v2 = t2.variable.map { occurs($0, t1) ? infinite : .right([$0: t1]) }

	if let v = v1 ?? v2 { return v }

	let recur: ((Term, Term), (Term, Term)) -> Either<Error, Substitution> = { (unify($0.0, $1.0) &&& unify($0.1, $1.1)).map(uncurry(Substitution.compose)) }

	let function = (t1.function &&& t2.function).map(recur)
	let sum = (t1.sum &&& t2.sum).map(recur)
	let product = (t1.product &&& t2.product).map(recur)
	return function ?? sum ?? product ?? .left("don’t know how to unify \(t1) with \(t2)")
}


public func checkForInconsistencies(partition: [Term]) -> (Error?, Substitution) {
	typealias Result = (Error?, Substitution, Term)
	let result: Result = reduce(dropFirst(partition), (nil, [:], partition[0])) { into, each in
		unify(into.2, each).either(
			ifLeft: { error in (into.0.map { $0 + error } ?? error, into.1, each) },
			ifRight: { (into.0, into.1.compose($0), each) })
	}
	return (result.0, result.1)
}

public func solve(constraints: ConstraintSet) -> Either<Error, Substitution> {
	func findOrAdd(type: Term, inout equivalences: DisjointSet<Term>, inout indices: [Term: Int]) -> Int {
		if let index = indices[type] { return index }
		let index = equivalences.count
		indices[type] = index
		equivalences.append(type)
		return index
	}
	let (graph: DisjointSet<Term>, indexByType: [Term: Int]) = reduce(constraints, ([], [:])) { (pair, constraint) in
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
