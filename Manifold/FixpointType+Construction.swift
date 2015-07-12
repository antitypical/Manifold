//  Copyright © 2015 Rob Rix. All rights reserved.

extension FixpointType {
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
}
