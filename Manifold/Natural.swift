//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Binding<Recur> {
		// Natural : Type
		// Natural = λ tag : Boolean . if tag then Natural else Unit
		return Binding("Natural",
			lambda(.BooleanType) { .If($0, .Variable("Natural"), .UnitType) },
			lambda(.BooleanType, const(.Type(0))))
	}

	public static var zero: Binding<Recur> {
		// zero : Natural
		// zero = (false, ()) : Natural
		return Binding("zero",
			.Annotation(.Product(.Boolean(false), .Unit), .Variable("Natural")),
			.Variable("Natural"))
	}

	public static var successor: Binding<Recur> {
		// successor : Natural -> Natural
		// successor = λ n : Natural . (true, n) : Natural
		return Binding("successor",
			lambda(.Variable("Natural")) { predecessor in .Annotation(.Product(.Boolean(true), predecessor), .Variable("Natural")) },
			lambda(.Variable("Natural"), const(.Variable("Natural"))))
	}

	public static var natural: Module<Recur> {
		return Module(Natural, zero, successor)
	}
}


import Prelude
