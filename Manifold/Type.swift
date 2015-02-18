//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Type: Hashable, Printable {
	public init(_ base: BaseType) {
		self = Base(base)
	}

	public init(_ variable: Manifold.Variable) {
		self = Variable(variable)
	}

	public init(function t1: Type, _ t2: Type) {
		self = Function(Box(t1), Box(t2))
	}

	public init(forall a: Set<Manifold.Variable>, _ t: Type) {
		self = Universal(a, Box(t))
	}


	public enum BaseType: Hashable, Printable {
		case Unit
		case Bool


		public func analysis<T>(@autoclosure #ifUnit: () -> T, @autoclosure ifBool: () -> T) -> T {
			switch self {
			case Unit:
				return ifUnit()
			case Bool:
				return ifBool()
			}
		}


		// MARK: Hashable

		public var hashValue: Int {
			return description.hashValue
		}


		// MARK: Printable

		public var description: String {
			return analysis(
				ifUnit: "Unit",
				ifBool: "Bool")
		}
	}


	case Base(BaseType)
	case Variable(Manifold.Variable)
	case Function(Box<Type>, Box<Type>)
	case Universal(Set<Manifold.Variable>, Box<Type>)


	// MARK: Categorization

	public var isVariable: Bool {
		return analysis(
			ifBase: const(false),
			ifVariable: const(true),
			ifFunction: const(false),
			ifUniversal: const(false))
	}

	public var isFunction: Bool {
		return analysis(
			ifBase: const(false),
			ifVariable: const(false),
			ifFunction: const(true),
			ifUniversal: const(false))
	}


	// MARK: Decomposition

	public var base: BaseType? {
		return analysis(
			ifBase: id,
			ifVariable: const(nil),
			ifFunction: const(nil),
			ifUniversal: const(nil))
	}

	public var variable: Manifold.Variable? {
		return analysis(
			ifBase: const(nil),
			ifVariable: id,
			ifFunction: const(nil),
			ifUniversal: const(nil))
	}

	public var function: (Type, Type)? {
		return analysis(
			ifBase: const(nil),
			ifVariable: const(nil),
			ifFunction: id,
			ifUniversal: const(nil))
	}

	public var universal: (Set<Manifold.Variable>, Type)? {
		return analysis(
			ifBase: const(nil),
			ifVariable: const(nil),
			ifFunction: const(nil),
			ifUniversal: id)
	}


	public var freeVariables: Set<Manifold.Variable> {
		return analysis(
			ifBase: const([]),
			ifVariable: { [ $0 ] },
			ifFunction: { $0.freeVariables.union($1.freeVariables) },
			ifUniversal: { $1.freeVariables.subtract($0) })
	}


	public var distinctTypes: Set<Type> {
		return analysis(
			ifBase: const([ self ]),
			ifVariable: const([ self ]),
			ifFunction: { $0.distinctTypes.union($1.distinctTypes).union([ self ]) },
			ifUniversal: { $1.distinctTypes.union([ self ]) })
	}

	public var quantifiedType: Type? {
		return analysis(
			ifBase: const(nil),
			ifVariable: const(nil),
			ifFunction: const(nil),
			ifUniversal: { $1.quantifiedType ?? $1 })
	}


	// MARK: Transformation

	public func instantiate() -> Type {
		return analysis(
			ifBase: const(self),
			ifVariable: const(self),
			ifFunction: { Type(function: $0.instantiate(), $1.instantiate()) },
			ifUniversal: { parameters, type in
				Substitution(lazy(parameters).map { ($0, Type(Manifold.Variable())) }).apply(type.instantiate())
			})
	}


	public func analysis<T>(#ifBase: BaseType -> T, ifVariable: Manifold.Variable -> T, ifFunction: (Type, Type) -> T, ifUniversal: (Set<Manifold.Variable>, Type) -> T) -> T {
		switch self {
		case let Base(t):
			return ifBase(t)

		case let Variable(v):
			return ifVariable(v)

		case let Function(t1, t2):
			return ifFunction(t1.value, t2.value)

		case let Universal(a, t):
			return ifUniversal(a, t.value)
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(
			ifBase: { $0.hashValue },
			ifVariable: { $0.hashValue },
			ifFunction: { $0.hashValue ^ $1.hashValue },
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
			ifBase: { $0.description },
			ifVariable: { (boundVariables.contains($0) ? bound : free) + $0.value.subscriptedDescription },
			ifFunction: { t1, t2 in
				let parameter = t1.describe(boundVariables) |> { t1.quantifiedType?.isFunction ?? t1.isFunction ? "(\($0))" : $0 }
				return "\(parameter) → \(t2.describe(boundVariables))"
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
	switch (left, right) {
	case let (.Base(b1), .Base(b2)):
		return b1 == b2

	case let (.Variable(x), .Variable(y)):
		return x == y

	case let (.Function(x1, x2), .Function(y1, y2)):
		return x1.value == y1.value && x2.value == y2.value

	case let (.Universal(a1, t1), .Universal(a2, t2)):
		return a1 == a2 && t1 == t2

	default:
		return false
	}
}


public func == (left: Type.BaseType, right: Type.BaseType) -> Bool {
	switch (left, right) {
	case (.Unit, .Unit), (.Bool, .Bool):
		return true

	default:
		return false
	}
}


infix operator --> {
	associativity right
}

public func --> (left: Type, right: Type) -> Type {
	return Type(function: left, right)
}

public func --> (left: Type.BaseType, right: Type) -> Type {
	return Type(function: .Base(left), right)
}

public func --> (left: Type, right: Type.BaseType) -> Type {
	return Type(function: left, .Base(right))
}

public func --> (left: Type.BaseType, right: Type.BaseType) -> Type {
	return Type(function: .Base(left), .Base(right))
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
