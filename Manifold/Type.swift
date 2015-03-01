//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type: Hashable, Printable {
	public init(_ variable: Manifold.Variable) {
		self = Variable(variable)
	}

	public init(_ constructor: Constructor<Type>) {
		self = Constructed(Box(constructor))
	}

	public init(function t1: Type, _ t2: Type) {
		self = Constructed(Box(.Function(t1, t2)))
	}

	public init(sum t1: Type, _ t2: Type) {
		self = Constructed(Box(.Sum(t1, t2)))
	}

	public init(forall a: Set<Manifold.Variable>, _ t: Type) {
		self = Universal(a, Box(t))
	}


	public static var Bool: Type {
		return Type(sum: .Unit, .Unit)
	}

	public static var Unit: Type {
		return Type(.Unit)
	}


	case Variable(Manifold.Variable)
	case Constructed(Box<Constructor<Type>>)
	case Universal(Set<Manifold.Variable>, Box<Type>)


	// MARK: Decomposition

	public var variable: Manifold.Variable? {
		return analysis(
			ifVariable: unit,
			ifConstructed: const(nil),
			ifUniversal: const(nil))
	}

	public var constructed: Constructor<Type>? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: unit,
			ifUniversal: const(nil))
	}

	public var function: (Type, Type)? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: { $0.function },
			ifUniversal: { $1.function })
	}

	public var sum: (Type, Type)? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: { $0.sum },
			ifUniversal: { $1.sum })
	}

	public var universal: (Set<Manifold.Variable>, Type)? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: const(nil),
			ifUniversal: unit)
	}


	public var freeVariables: Set<Manifold.Variable> {
		return analysis(
			ifVariable: { [ $0 ] },
			ifConstructed: { $0.reduce([]) { $0.union($1.freeVariables) } },
			ifUniversal: { $1.freeVariables.subtract($0) })
	}


	public var distinctTypes: Set<Type> {
		return reduce([]) { $0.union([ $1 ]) }
	}

	public var quantifiedType: Type? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: const(nil),
			ifUniversal: { $1.quantifiedType ?? $1 })
	}


	// MARK: Transformation

	public func instantiate() -> Type {
		return analysis(
			ifVariable: const(self),
			ifConstructed: {
				$0.analysis(
					ifUnit: self,
					ifFunction: { Type(function: $0.instantiate(), $1.instantiate()) },
					ifSum: { Type(sum: $0.instantiate(), $1.instantiate()) })
			},
			ifUniversal: { parameters, type in
				Substitution(lazy(parameters).map { ($0, Type(Manifold.Variable())) }).apply(type.instantiate())
			})
	}


	// MARK: Case analysis

	public func analysis<Result>(@noescape #ifVariable: Manifold.Variable -> Result, @noescape ifConstructed: Constructor<Type> -> Result, @noescape ifUniversal: (Set<Manifold.Variable>, Type) -> Result) -> Result {
		switch self {
		case let Variable(v):
			return ifVariable(v)

		case let Constructed(c):
			return ifConstructed(c.value)

		case let Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}

	public func reduce<Result>(initial: Result, @noescape _ combine: (Result, Type) -> Result) -> Result {
		return analysis(
			ifVariable: { _ in combine(initial, self) },
			ifConstructed: { combine($0.reduce(initial, combine), self) },
			ifUniversal: { combine($1.reduce(initial, combine), self) })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(
			ifVariable: { $0.hashValue },
			ifConstructed: { $0.hashValue },
			ifUniversal: { $0.hashValue ^ $1.hashValue }
		)
	}


	// MARK: Printable

	public var description: String {
		return describe()
	}

	private func describe(_ boundVariables: Set<Manifold.Variable> = []) -> String {
		let bound = "α"
		let free = "τ"
		return analysis(
			ifVariable: { (boundVariables.contains($0) ? bound : free) + $0.value.subscriptedDescription },
			ifConstructed: { c in
				c.analysis(
					ifUnit: "Unit",
					ifFunction: { t1, t2 in
						let d1 = t1.describe(boundVariables)
						let parameter = t1.function ?? t1.sum != nil ?
							"(\(d1))"
						:	d1
						return "\(parameter) → \(t2.describe(boundVariables))"
					},
					ifSum: { "\($0) | \($1)" })
			},
			ifUniversal: {
				let variables = lazy($0)
					.map { bound + $0.value.subscriptedDescription }
					|> sorted
					|> (join <| ",")
				return "∀{\(variables)}.\($1.describe(boundVariables.union($0)))"
			})
	}
}


public func == (left: Type, right: Type) -> Bool {
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let constructed: Bool? = (left.constructed &&& right.constructed).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return variable ?? constructed ?? universal ?? false
}


infix operator --> {
	associativity right
}

public func --> (left: Type, right: Type) -> Type {
	return Type(function: left, right)
}


// MARK: - Implementation details

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
import Set
