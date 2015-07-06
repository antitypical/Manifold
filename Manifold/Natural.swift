//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Expression {
		return lambda(Recur(.BooleanType)) { Recur(.If($0, Recur(.Variable("Natural")), Recur(.UnitType))) }
	}

	public static var zero: Expression {
		return .Annotation(Recur(.Product(Recur(false), Recur(.Unit))), Recur(.Variable("Natural")))
	}

	public static var successor: Expression {
		return lambda(Recur(.Variable("Natural"))) { predecessor in Recur(lambda(Recur(true), const(predecessor))) }
	}

	public static var naturalEnvironment: [Name: Expression] {
		return [
			"Natural": Natural,
			"zero": zero,
			"successor": successor,
		]
	}

	public static var naturalContext: [Name: Expression] {
		return [
			"Natural": lambda(Recur(.BooleanType), const(Recur(.Type(0)))),
			"zero": .Variable("Natural"),
			"successor": lambda(Recur(.Variable("Natural")), const(Recur(.Variable("")))),
		]
	}
}


import Prelude
