//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	// MARK: First-order construction

	public static var Unit: Self {
		return Self(.Unit)
	}

	public static var UnitType: Self {
		return Self(.UnitType)
	}

	public static var Type: Self {
		return Type(0)
	}

	public static func Type(n: Int) -> Self {
		return Self(.Type(n))
	}

	public static func Variable(name: Name) -> Self {
		return Self(.Variable(name))
	}

	public static func Application(a: Self, _ b: Self) -> Self {
		return Self(.Application(a, b))
	}

	public static func Lambda(i: Int, _ type: Self, _ body: Self) -> Self {
		return Self(.Lambda(i, type, body))
	}

	public static func Projection(a: Self, _ field: Bool) -> Self {
		return Self(.Projection(a, field))
	}

	public static func Product(a: Self, _ b: Self) -> Self {
		return Self(.Product(a, b))
	}

	public static var BooleanType: Self {
		return Self(.BooleanType)
	}

	public static func Boolean(value: Bool) -> Self {
		return Self(.Boolean(value))
	}

	public static func If(condition: Self, _ then: Self, _ `else`: Self) -> Self {
		return Self(.If(condition, then, `else`))
	}

	public static func Annotation(term: Self, _ type: Self) -> Self {
		return Self(.Annotation(term, type))
	}


	public static func FunctionType(a: Self, _ b: Self) -> Self {
		return .Lambda(-1, a, b)
	}

	public static func FunctionType(a: Self, _ b: Self, _ c: Self) -> Self {
		return FunctionType(a, FunctionType(b, c))
	}


	/// Constructs a sum type of the elements in `terms`.
	public static func Sum(terms: [Self]) -> Self {
		return terms.uncons.map { first, rest in
			rest.isEmpty
				? first
				: Self.lambda(.BooleanType) {
					.If($0, first, .Sum(Array(rest)))
				}
		} ?? .UnitType
	}


	public subscript (operands: Self...) -> Self {
		return operands.reduce(self, combine: Self.Application)
	}


	public var first: Self {
		return .Projection(self, false)
	}

	public var second: Self {
		return .Projection(self, true)
	}


	// MARK: Higher-order construction

	public static func lambda(type: Self, _ body: Self -> Self) -> Self {
		return Self(.lambda(type, body))
	}

	public static func lambda(type1: Self, _ type2: Self, _ body: (Self, Self) -> Self) -> Self {
		return Self(.lambda(type1, type2, body))
	}

	public static func lambda(type1: Self, _ type2: Self, _ type3: Self, _ body: (Self, Self, Self) -> Self) -> Self {
		return Self(.lambda(type1, type2, type3, body))
	}

	public static func lambda(type1: Self, _ type2: Self, _ type3: Self, _ type4: Self, _ body: (Self, Self, Self, Self) -> Self) -> Self {
		return Self(.lambda(type1, type2, type3, type4, body))
	}


	public init<T: TermType>(term: T) {
		self.init(term.out.map { Self(term: $0) })
	}

	public init<T: TermType>(expression: Expression<T>) {
		self.init(expression.map { Self(term: $0) })
	}


	public init(booleanLiteral value: Bool) {
		self.init(.Boolean(value))
	}


	public init(integerLiteral value: Int) {
		self.init(.Variable(.Local(value)))
	}


	public init(stringLiteral value: String) {
		self.init(.Variable(.Global(value)))
	}

	public init(unicodeScalarLiteral: Self.StringLiteralType) {
		self.init(stringLiteral: unicodeScalarLiteral)
	}

	public init(extendedGraphemeClusterLiteral: Self.StringLiteralType) {
		self.init(stringLiteral: extendedGraphemeClusterLiteral)
	}


	// MARK: Variables

	var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: max,
				ifLambda: { max($0.0, $0.1) },
				ifProjection: { $0.0 },
				ifProduct: max,
				ifIf: { max($0, $1, $2) },
				ifAnnotation: max,
				otherwise: const(-1))
		} (self)
	}

	public var freeVariables: Set<Int> {
		return cata {
			$0.analysis(
				ifVariable: { $0.local.map { [ $0 ] } ?? Set() },
				ifApplication: uncurry(Set.union),
				ifLambda: { $1.union($2.subtract([ $0 ])) },
				ifProjection: { $0.0 },
				ifProduct: uncurry(Set.union),
				ifIf: { $0.union($1).union($2) },
				ifAnnotation: uncurry(Set.union),
				otherwise: const(Set()))
		} (self)
	}
}


import Prelude
