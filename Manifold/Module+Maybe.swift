//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var maybe: Module {
		let Maybe = Declaration.Datatype("Maybe", .Argument(.Type, {
			[
				"just": .Argument($0, const(.End)),
				"nothing": .End
			]
		}))

		let map = Declaration("Maybe.map",
			type: (.Type, .Type) => { A, B in (A --> B) --> Maybe.ref[A] --> Maybe.ref[B] },
			value: .Type)

		return Module("Maybe", [ Maybe, map ])
	}
}


import Prelude
