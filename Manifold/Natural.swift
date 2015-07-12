//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var Natural: Expression {
		return lambda(Recur(.BooleanType)) { Recur(.If($0, Recur(.Variable("Natural")), Recur(.UnitType))) }
	}

	public static var zero: Expression {
		return .Annotation(Recur(.Product(Recur(false), Recur(.Unit))), Recur(.Variable("Natural")))
	}

	public static var successor: Expression {
		return lambda(Recur(.Variable("Natural"))) { predecessor in Recur(.Annotation(Recur(lambda(Recur(true), const(predecessor))), Recur(.Variable("Natural")))) }
	}

	public static var natural: Space {
		return defineSpace([
			("Natural", Natural, lambda(Recur(.BooleanType), const(Recur(.Type(0))))),
			("zero", zero, .Variable("Natural")),
			("successor", successor, lambda(Recur(.Variable("Natural")), const(Recur(.Variable("Natural")))))
		])
	}
}


import Prelude
