//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType, Hashable, IntegerLiteralConvertible, Printable {
	public init() {
		self.type = Type.Variable(Variable())
	}

	public init(_ type: Recur) {
		self.type = type
	}

	public init(_ variable: Manifold.Variable) {
		self.init(.Variable(variable))
	}

	public static func variable(v: Manifold.Variable) -> Term {
		return In(Type.variable(v))
	}

	public static func constructed(c: Constructor<Term>) -> Term {
		return In(Type.constructed(c))
	}

	public static func function(t1: Term, _ t2: Term) -> Term {
		return constructed(Constructor.function(t1, t2))
	}

	public static func sum(t1: Term, _ t2: Term) -> Term {
		return constructed(Constructor.sum(t1, t2))
	}

	public static func product(t1: Term, _ t2: Term) -> Term {
		return constructed(Constructor.product(t1, t2))
	}

	public static func forall(a: Set<Manifold.Variable>, _ t: Term) -> Term {
		return (a.intersect(t.freeVariables)).count > 0 ?
			In(Type.universal(a, t))
		:	t
	}


	public static var Unit: Term {
		return Term(.Unit)
	}

	public static var Bool: Term {
		return sum(Unit, Unit)
	}


	public let type: Type<Term>


	public var freeVariables: Set<Variable> {
		let binary: (Term, Term) -> Set<Variable> = { $0.freeVariables.union($1.freeVariables) }
		return type.analysis(
			ifVariable: { [ $0 ] },
			ifUnit: const([]),
			ifFunction: binary,
			ifSum: binary,
			ifProduct: binary,
			ifConstructed: { $0.reduce([]) { $0.union($1.freeVariables) } },
			ifUniversal: { $1.freeVariables.subtract($0) })
	}

	public var boundVariables: Set<Variable> {
		return type.analysis(
			ifUniversal: { variables, _ in variables },
			otherwise: const([]))
	}

	public func generalize(environment: Environment = [:]) -> Term {
		return Term.forall(freeVariables.subtract(environment.freeVariables), self)
	}


	/// Returns the receiver’s arity.
	///
	/// For (possibly quantified) function types, this will be at least one, for all other types, zero.
	public var arity: Int {
		return parameters.count
	}

	/// Returns the receiver’s parameters.
	///
	/// For (possibly quantified) function types, this will have at least one element, for all other types, it will be empty.
	public var parameters: [Term] {
		func parameters(type: Type<(Term, [Term])>) -> [Term] {
			return type.analysis(
				ifFunction: { [ $0.0 ] + $1.1 },
				ifConstructed: {
					$0.analysis(
						ifUnit: [],
						ifFunction: {
							[ $0.0 ] + $1.1
						},
						ifSum: const([]),
						ifProduct: const([]))
				},
				ifUniversal: { $1.1 },
				otherwise: const([]))
		}
		return para(parameters)(self)
	}

	/// Returns a function’s return type, defaulting to `self` if not a function type.
	public var `return`: Term {
		return function?.1.`return` ?? universal?.1.`return` ?? self
	}

	/// Returns the fields of a function’s return type, defaulting to `[return]` if not a function type.
	public var returns: [Term] {
		return `return`.product.map { [$0] + $1.returns } ?? [`return`]
	}


	public var distinctTerms: Set<Term> {
		return cata(Term.distinctTerms)(self)
	}

	private static func distinctTerms(type: Type<Set<Term>>) -> Set<Term> {
		let binary: (Set<Term>, Set<Term>) -> Set<Term> = { $0.union($1) }
		return type.analysis(
			ifFunction: binary,
			ifConstructed: {
				$0.analysis(
					ifUnit: [],
					ifFunction: binary,
					ifSum: binary,
					ifProduct: binary)
			},
			ifUniversal: { $1 },
			otherwise: const([]))
	}

	public func instantiate(_ freshVariable: (() -> Variable)? = nil) -> Term {
		func instantiate(type: Type<Term>) -> Term {
			let binary: (Term, Term) -> (Term, Term) = { ($0.instantiate(freshVariable), $1.instantiate(freshVariable)) }
			return type.analysis(
				ifFunction: binary >>> Term.function,
				ifConstructed: {
					$0.analysis(
						ifUnit: Term(type),
						ifFunction: binary >>> Term.function,
						ifSum: binary >>> Term.sum,
						ifProduct: binary >>> Term.product)
				},
				ifUniversal: { parameters, type in
					Substitution(lazy(parameters).map { ($0, Term(freshVariable?() ?? Manifold.Variable())) }).apply(type.instantiate(freshVariable))
				},
				otherwise: const(Term(type)))
		}
		return cata(instantiate)(self)
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
			ifFunction: unit,
			ifConstructed: { $0.function },
			ifUniversal: { $1.function },
			otherwise: const(nil))
	}

	public var isUnit: Swift.Bool {
		return type.isUnit
	}

	public var sum: (Term, Term)? {
		return type.analysis(
			ifConstructed: { $0.sum },
			ifUniversal: { $1.sum },
			otherwise: const(nil))
	}

	public var product: (Term, Term)? {
		return type.analysis(
			ifConstructed: { $0.product },
			ifUniversal: { $1.product },
			otherwise: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, Term)? {
		return type.analysis(
			ifUniversal: unit,
			otherwise: const(nil))
	}


	// MARK: Hashable

	public var hashValue: Int {
		return type.analysis(
			ifVariable: { $0.hashValue },
			ifUnit: { 1 },
			ifFunction: hash(2),
			ifSum: hash(3),
			ifProduct: hash(4),
			ifConstructed: {
				$0.analysis(
					ifUnit: 1,
					ifFunction: hash(2),
					ifSum: hash(3),
					ifProduct: hash(4))
			},
			ifUniversal: hash(-1))
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: IntegerLiteralType) {
		self.init(Manifold.Variable(integerLiteral: value))
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
		return para(toStringWithBoundVariables([]))(self)
	}
}


public func == (left: Term, right: Term) -> Bool {
	return left.type == right.type
}


// MARK: - Implementation details

private func hash<A: Hashable, B: Hashable>(n: Int)(a: A, b: B) -> Int {
	return n ^ a.hashValue ^ b.hashValue
}

/// Parenthesizes its argument.
private func parenthesize(string: String) -> String {
	return "(\(string))"
}

/// Describes a type given a set of bound variables.
///
/// This would be nested within `Type.description`, but that crashes the Swift compiler.
private func toStringWithBoundVariables(boundVariables: Set<Variable>)(type: Type<(Term, String)>) -> String {
	let bound = "α"
	let free = "τ"
	return type.analysis(
		ifVariable: { (boundVariables.contains($0) ? bound : free) + $0.value.subscriptedDescription },
		ifUnit: const("Unit"),
		ifFunction: { t1, t2 in
			"\((t1.0.function ?? t1.0.sum != nil ? parenthesize : id)(t1.1)) → \(t2.1)"
		},
		ifSum: { "\($0.1) | \($1.1)" },
		ifProduct: { "(\($0.1), \($1.1))" },
		ifConstructed: { c in
			c.analysis(
				ifUnit: "Unit",
				ifFunction: { t1, t2 in
					"\((t1.0.function ?? t1.0.sum != nil ? parenthesize : id)(t1.1)) → \(t2.1)"
				},
				ifSum: { "\($0.1) | \($1.1)" },
				ifProduct: { "(\($0.1), \($1.1))" })
		},
		ifUniversal: {
			let variables = lazy($0)
				.map { bound + $0.value.subscriptedDescription }
				|> sorted
				|> (join <| ",")
			return "∀{\(variables)}.\(para(toStringWithBoundVariables(boundVariables.union($0)))($1.0))"
		})
}

extension Int {
	private var digits: [UInt32] {
		var digits: [UInt32] = []
		var remainder = abs(self)
		do {
			digits.append(UInt32(remainder % 10))
			remainder /= 10
		} while remainder > 0

		return digits.reverse()
	}

	private var subscriptedDescription: String {
		let zero: UnicodeScalar = "₀"
		return (self < 0 ? "₋" : "") + String(lazy(digits).map { Character(UnicodeScalar(zero.value + $0)) })
	}
}


// MARK: - Imports

import Box
import Prelude
