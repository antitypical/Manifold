//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type: Hashable, Printable {
	public init(_ variable: Manifold.Variable) {
		self = Variable(variable)
	}

	public init(_ constructor: Constructor) {
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
		return Type(.Bool)
	}

	public static var Unit: Type {
		return Type(.Unit)
	}


	public enum Constructor: Hashable, Printable {
		case Unit
		case Bool
		case Function(Type, Type)
		case Sum(Type, Type)


		// MARK: Decomposition

		public var isUnit: Swift.Bool {
			return analysis(
				ifUnit: true,
				ifBool: false,
				ifFunction: const(false),
				ifSum: const(false))
		}

		public var isBool: Swift.Bool {
			return analysis(
				ifUnit: false,
				ifBool: true,
				ifFunction: const(false),
				ifSum: const(false))
		}

		public var function: (Type, Type)? {
			return analysis(
				ifUnit: nil,
				ifBool: nil,
				ifFunction: unit,
				ifSum: const(nil))
		}


		// MARK: Recursive properties

		public var freeVariables: Set<Manifold.Variable> {
			return reduce([]) { $0.union($1.freeVariables) }
		}

		public var distinctTypes: Set<Type> {
			return reduce([]) { $0.union($1.distinctTypes) }
		}


		// MARK: Case analysis

		public func analysis<T>(@autoclosure #ifUnit: () -> T, @autoclosure ifBool: () -> T, @noescape ifFunction: (Type, Type) -> T, @noescape ifSum: (Type, Type) -> T) -> T {
			switch self {
			case Unit:
				return ifUnit()
			case Bool:
				return ifBool()
			case let Function(t1, t2):
				return ifFunction(t1, t2)
			case let Sum(t1, t2):
				return ifSum(t1, t2)
			}
		}

		public func reduce<Result>(initial: Result, @noescape _ combine: (Result, Type) -> Result) -> Result {
			return analysis(
				ifUnit: initial,
				ifBool: initial,
				ifFunction: { combine(combine(initial, $0), $1) },
				ifSum: { combine(combine(initial, $0), $1) })
		}


		// MARK: Hashable

		public var hashValue: Int {
			let hash: Int -> (Type, Type) -> Int = { n in { n ^ $0.hashValue ^ $1.hashValue } }
			return analysis(
				ifUnit: 0,
				ifBool: 1,
				ifFunction: hash(2),
				ifSum: hash(3))
		}


		// MARK: Printable

		public var description: String {
			return describe()
		}

		private func describe(_ boundVariables: Set<Manifold.Variable> = []) -> String {
			return analysis(
				ifUnit: "Unit",
				ifBool: "Bool",
				ifFunction: { t1, t2 in
					let parameter = t1.describe(boundVariables) |> { (t1.quantifiedType?.function ?? t1.function).map(const("(\($0))")) ?? $0 }
					return "\(parameter) → \(t2.describe(boundVariables))"
				},
				ifSum: { "\($0) | \($1)" })
		}
	}


	case Variable(Manifold.Variable)
	case Constructed(Box<Constructor>)
	case Universal(Set<Manifold.Variable>, Box<Type>)


	// MARK: Decomposition

	public var variable: Manifold.Variable? {
		return analysis(
			ifVariable: unit,
			ifConstructed: const(nil),
			ifUniversal: const(nil))
	}

	public var constructed: Constructor? {
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

	public var universal: (Set<Manifold.Variable>, Type)? {
		return analysis(
			ifVariable: const(nil),
			ifConstructed: const(nil),
			ifUniversal: unit)
	}


	public var freeVariables: Set<Manifold.Variable> {
		return analysis(
			ifVariable: { [ $0 ] },
			ifConstructed: { $0.freeVariables },
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
					ifBool: self,
					ifFunction: { Type(function: $0.instantiate(), $1.instantiate()) },
					ifSum: { Type(sum: $0.instantiate(), $1.instantiate()) })
			},
			ifUniversal: { parameters, type in
				Substitution(lazy(parameters).map { ($0, Type(Manifold.Variable())) }).apply(type.instantiate())
			})
	}


	// MARK: Case analysis

	public func analysis<T>(@noescape #ifVariable: Manifold.Variable -> T, @noescape ifConstructed: Constructor -> T, @noescape ifUniversal: (Set<Manifold.Variable>, Type) -> T) -> T {
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
				c.describe(boundVariables)
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

public func == <T: Equatable, U: Equatable> (left: (T, U), right: (T, U)) -> Bool {
	return left.0 == right.0 && left.1 == right.1
}

public func == (left: Type, right: Type) -> Bool {
	let variable: Bool? = (left.variable &&& right.variable).map(==)
	let constructed: Bool? = (left.constructed &&& right.constructed).map(==)
	let universal: Bool? = (left.universal &&& right.universal).map(==)
	return variable ?? constructed ?? universal ?? false
}

public func == (left: Type.Constructor, right: Type.Constructor) -> Bool {
	return
		(left.isUnit && right.isUnit)
	||	(left.isBool && right.isBool)
	||	((left.function &&& right.function).map(==) ?? false)
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
