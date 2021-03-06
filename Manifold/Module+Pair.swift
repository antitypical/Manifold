//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var pair: Module {
		let Pair = Declaration("Pair", Datatype("A", .Type, "B", .Type,
			[ "pair": .Argument("a", "A", .Argument("b", "B", .End)) ]
		))

		let first = Declaration("first",
			type: (nil, nil) => { A, B in Pair.ref[A, B] --> A },
			value: (nil, nil, nil) => { A, B, pair in pair[nil, (nil, B) => { a, _ in a }] })

		let second = Declaration("second",
			type: (nil, nil) => { A, B in Pair.ref[A, B] --> B },
			value: (nil, nil, nil) => { A, B, pair in pair[nil, (nil, nil) => { _, b in b }] })

		return Module("Pair", [ Pair, first, second ])
	}
}
