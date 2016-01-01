//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var maybe: Module {
		let Maybe = Declaration.Datatype("Maybe", .Argument("A", .Type,
			[
				"just": .Argument("a", "A", .End),
				"nothing": .End
			]
		))

		let just: Term = "just"
		let nothing: Term = "nothing"
		let map = Declaration("Maybe.map",
			type: (nil, nil) => { A, B in (A --> B) --> Maybe.ref[A] --> Maybe.ref[B] },
			value: (nil, nil) => { A, B in (A --> B, nil) => { transform, maybe in maybe[nil, nil => { just[nil, transform[$0]] }, nothing[Term.Implicit]] } })

		return Module("Maybe", [ Maybe, map ])
	}
}
