//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Definition {
		return (
			symbol: "Natural",
			value: lambda(.BooleanType) { .If($0, .Variable("Natural"), .UnitType) },
			type: lambda(.BooleanType, const(.Type(0))))
	}

	public static var zero: Definition {
		return (
			symbol: "zero",
			value: .Annotation(.Product(.Boolean(false), .Unit), .Variable("Natural")),
			type: .Variable("Natural"))
	}

	public static var successor: Definition {
		return (
			symbol: "successor",
			value: lambda(.Variable("Natural")) { predecessor in .Annotation(.lambda(.Boolean(true), const(predecessor)), .Variable("Natural")) },
			type: lambda(.Variable("Natural"), const(.Variable("Natural"))))
	}

	public static var natural: Space {
		return defineSpace([
			Natural,
			zero,
			successor
		])
	}
}


import Prelude
