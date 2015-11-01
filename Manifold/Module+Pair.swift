//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var pair: Module {
		let Pair = Declaration("Pair", Datatype(.Type, .Type) {
			[ "pair": .Argument($0, const(.Argument($1, const(.End)))) ]
		})

		let first = Declaration("first",
			type: () => { A, B in Pair.ref[A, B] --> A },
			value: () => { A, B in () => { pair in pair[A, (nil, B) => { a, _ in a }] } })

		let second = Declaration("second",
			type: () => { A, B in Pair.ref[A, B] --> B },
			value: () => { A, B in () => { pair in pair[B, () => { _, b in b }] } })

		return Module("Pair", [ Pair, first, second ])
	}
}


import Prelude
