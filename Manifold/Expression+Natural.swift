//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var natural: Module<Recur> {
		// Natural : Type
		// Natural = λ tag : Boolean . if tag then Natural else Unit
		let Natural = Binding("Natural",
			lambda(.BooleanType) { .If($0, .Variable("Natural"), .UnitType) },
			.Type(0))

		// zero : Natural
		// zero = (false, ()) : Natural
		let zero = Binding("zero",
			.Product(Recur.Boolean(false), .Unit),
			"Natural")

		// successor : Natural -> Natural
		// successor = λ n : Natural . (true, n) : Natural
		let successor = Binding("successor",
			lambda(.Variable("Natural")) { predecessor in .Product(.Boolean(true), predecessor) },
			lambda(.Variable("Natural"), const(.Variable("Natural"))))

		return Module([ Natural, zero, successor ])
	}
}


import Prelude
