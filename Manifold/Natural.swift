//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Definition {
		// Natural : Type
		// Natural = λ tag : Boolean . if tag then Natural else Unit
		return (symbol: "Natural",
			value: lambda(.BooleanType) { .If($0, .Variable("Natural"), .UnitType) },
			type: lambda(.BooleanType, const(.Type(0))))
	}

	public static var zero: Definition {
		// zero : Natural
		// zero = (false, ()) : Natural
		return (symbol: "zero",
			value: .Annotation(.Product(.Boolean(false), .Unit), .Variable("Natural")),
			type: .Variable("Natural"))
	}

	public static var successor: Definition {
		// successor : Natural -> Natural
		// successor = λ n : Natural . (true, n) : Natural
		return (symbol: "successor",
			value: lambda(.Variable("Natural")) { predecessor in .Annotation(.Product(.Boolean(true), predecessor), .Variable("Natural")) },
			type: lambda(.Variable("Natural"), const(.Variable("Natural"))))
	}

	public static var natural: Module<Recur> {
		return Module(Natural, zero, successor)
	}
}


import Prelude
