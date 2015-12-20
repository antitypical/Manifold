//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var maybe: Module {
		let Maybe = Declaration.Datatype("Maybe", .Argument(.Type, {
			[
				"just": .Argument($0, const(.End)),
				"nothing": .End
			]
		}))

		let just: Term = "just"
		let nothing: Term = "nothing"
		let map = Declaration("Maybe.map",
			type: (nil, nil) => { A, B in (A --> B) --> Maybe.ref[A] --> Maybe.ref[B] },
			value: (nil, nil) => { A, B in (A --> B, nil) => { transform, maybe in maybe[Maybe.ref[B], nil => { just[B, transform[$0]] }, nothing[B]] } })

		return Module("Maybe", [ Maybe, map ])
	}
}


import Prelude
