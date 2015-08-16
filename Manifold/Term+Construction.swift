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
		return Self(.FunctionType(a, b))
	}

	public static func FunctionType(a: Self, _ b: Self, _ c: Self) -> Self {
		return FunctionType(a, FunctionType(b, c))
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
}


import Prelude
