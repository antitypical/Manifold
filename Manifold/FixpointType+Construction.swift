//  Copyright © 2015 Rob Rix. All rights reserved.

extension FixpointType {
	public static var unit: Self {
		return Self(.Unit)
	}

	public static var unitType: Self {
		return Self(.UnitType)
	}

	public static var type: Self {
		return type(0)
	}

	public static func type(n: Int) -> Self {
		return Self(.Type(n))
	}

	public static func variable(name: Name) -> Self {
		return Self(.Variable(name))
	}

	public static func application(a: Self, _ b: Self) -> Self {
		return Self(.Application(a, b))
	}

	public static func lambda(i: Int, _ type: Self, _ body: Self) -> Self {
		return Self(.Lambda(i, type, body))
	}

	public static func projection(a: Self, _ field: Bool) -> Self {
		return Self(.Projection(a, field))
	}

	public static func product(a: Self, _ b: Self) -> Self {
		return Self(.Product(a, b))
	}

	public static var booleanType: Self {
		return Self(.BooleanType)
	}

	public static func boolean(value: Bool) -> Self {
		return Self(.Boolean(value))
	}

	public static func `if`(condition: Self, then: Self, `else`: Self) -> Self {
		return Self(.If(condition, then, `else`))
	}

	public static func annotation(term: Self, _ type: Self) -> Self {
		return Self(.Annotation(term, type))
	}
}
