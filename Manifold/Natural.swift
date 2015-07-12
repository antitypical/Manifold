//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Expression {
		return lambda(.BooleanType) { .If($0, .Variable("Natural"), .UnitType) }
	}

	public static var zero: Expression {
		return .Annotation(.Product(.Boolean(false), .Unit), .Variable("Natural"))
	}

	public static var successor: Expression {
		return lambda(.Variable("Natural")) { predecessor in .Annotation(.lambda(.Boolean(true), const(predecessor)), .Variable("Natural")) }
	}

	public static var natural: Space {
		return defineSpace([
			("Natural", Natural, lambda(.BooleanType, const(.Type(0)))),
			("zero", zero, .Variable("Natural")),
			("successor", successor, lambda(.Variable("Natural"), const(.Variable("Natural"))))
		])
	}
}


import Prelude
