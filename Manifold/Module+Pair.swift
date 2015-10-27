//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var pair: Module {
		let Pair = Declaration("Pair", Datatype(.Type, .Type) {
			[ "pair": .Argument($0, const(.Argument($1, const(.End)))) ]
		})

		let first = Declaration("first",
			type: (.Type, .Type) => { A, B in Pair.ref[A, B] --> A },
			value: (.Type, .Type) => { A, B in (Pair.ref[A, B]) => { pair in pair[A, (A, B) => { a, _ in a }] } })

		let second = Declaration("second",
			type: (.Type, .Type) => { A, B in Pair.ref[A, B] --> B },
			value: (.Type, .Type) => { A, B in (Pair.ref[A, B]) => { pair in pair[B, (A, B) => { _, b in b }] } })

		return Module("Pair", [ Pair, first, second ])
	}
}


import Prelude
