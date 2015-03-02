//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType, Hashable, Printable {
	public init(_ type: Recur) {
		self.type = type
	}

	public init(_ variable: Manifold.Variable) {
		self.init(.Variable(variable))
	}

	public init(_ constructor: Constructor<Term>) {
		self.init(.Constructed(Box(constructor)))
	}

	public init(function t1: Term, _ t2: Term) {
		self.init(.Function(Box(t1), Box(t2)))
	}

	public init(sum t1: Term, _ t2: Term) {
		self.init(.Sum(Box(t1), Box(t2)))
	}

	public init(forall a: Set<Manifold.Variable>, _ t: Term) {
		self.init(.Universal(a, Box(t)))
	}


	public static var Unit: Term {
		return Term(Type(.Unit))
	}

	public static var Bool: Term {
		return Term(Type(sum: .Unit, .Unit))
	}


	public let type: Type<Term>


	public var freeVariables: Set<Variable> {
		return type.analysis(
			ifVariable: { [ $0 ] },
			ifConstructed: { $0.reduce([]) { $0.union($1.freeVariables) } },
			ifUniversal: { $1.freeVariables.subtract($0) })
	}

	public var boundVariables: Set<Variable> {
		return type.analysis(
			ifVariable: const([]),
			ifConstructed: const([]),
			ifUniversal: { variables, _ in variables })
	}

	public var distinctTerms: Set<Term> {
		return cata(Term.distinctTerms)(self)
	}

	private static func distinctTerms(type: Type<Set<Term>>) -> Set<Term> {
		return type.analysis(
			ifVariable: const([]),
			ifConstructed: {
				$0.analysis(
					ifUnit: [],
					ifFunction: { $0.union($1) },
					ifSum: { $0.union($1) })
			},
			ifUniversal: { $1 })
	}

	public func instantiate() -> Term {
		return type.analysis(
			ifVariable: const(self),
			ifConstructed: {
				$0.analysis(
					ifUnit: self,
					ifFunction: { Term(function: $0.instantiate(), $1.instantiate()) },
					ifSum: { Term(sum: $0.instantiate(), $1.instantiate()) })
			},
			ifUniversal: { parameters, type in
				Substitution(lazy(parameters).map { ($0, Term(Manifold.Variable())) }).apply(type.instantiate())
			})
	}


	// MARK: Destructors

	public var variable: Manifold.Variable? {
		return type.variable
	}

	public var constructed: Constructor<Term>? {
		return type.constructed
	}

	public var function: (Term, Term)? {
		return type.analysis(
			ifVariable: const(nil),
			ifConstructed: { $0.function },
			ifUniversal: { $1.function })
	}

	public var sum: (Term, Term)? {
		return type.analysis(
			ifVariable: const(nil),
			ifConstructed: { $0.sum },
			ifUniversal: { $1.sum })
	}

	public var universal: (Set<Manifold.Variable>, Term)? {
		return type.analysis(
			ifVariable: const(nil),
			ifConstructed: const(nil),
			ifUniversal: unit)
	}



	// MARK: Hashable

	public var hashValue: Int {
		return type.analysis(
			ifVariable: { $0.hashValue },
			ifConstructed: {
				$0.analysis(
					ifUnit: 1,
					ifFunction: hash(2),
					ifSum: hash(3))
			},
			ifUniversal: hash(4))
	}


	// MARK: FixpointType

	public typealias Recur = Type<Term>

	public static func In(type: Recur) -> Term {
		return Term(type)
	}

	public static func out(term: Term) -> Recur {
		return term.type
	}


	// MARK: Printable

	public var description: String {
		return toString(self, [])
	}
}


public func == (left: Term, right: Term) -> Bool {
	return left.type == right.type
}


infix operator --> {
	associativity right
}

public func --> (left: Term, right: Term) -> Term {
	return Term(function: left, right)
}


// MARK: - Implementation details

private func hash<A: Hashable, B: Hashable>(n: Int)(a: A, b: B) -> Int {
	return n ^ a.hashValue ^ b.hashValue
}

/// Describes a type given a set of bound variables.
///
/// This would be nested within `Type.description`, but that crashes the Swift compiler.
private func toString(term: Term, boundVariables: Set<Manifold.Variable>) -> String {
	let bound = "α"
	let free = "τ"
	return term.type.analysis(
		ifVariable: { (boundVariables.contains($0) ? bound : free) + $0.value.subscriptedDescription },
		ifConstructed: { c in
			c.analysis(
				ifUnit: "Unit",
				ifFunction: { t1, t2 in
					let d1 = toString(t1, boundVariables)
					let parameter = t1.function ?? t1.sum != nil ?
						"(\(d1))"
					:	d1
					return "\(parameter) → \(toString(t2, boundVariables))"
				},
				ifSum: { "\($0) | \($1)" })
		},
		ifUniversal: {
			let variables = lazy($0)
				.map { bound + $0.value.subscriptedDescription }
				|> sorted
				|> (join <| ",")
			return "∀{\(variables)}.\(toString($1, boundVariables.union($0)))"
		})
}

extension Int {
	private var digits: [UInt32] {
		var digits: [UInt32] = []
		var remainder = self
		do {
			digits.append(UInt32(remainder % 10))
			remainder /= 10
		} while remainder > 0

		return digits.reverse()
	}

	private var subscriptedDescription: String {
		let zero: UnicodeScalar = "₀"
		return String(lazy(digits).map { Character(UnicodeScalar(zero.value + $0)) })
	}
}


// MARK: - Imports

import Box
import Prelude
