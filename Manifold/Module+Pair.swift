//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var pair: Module {
		let Pair = Declaration<Recur>("Pair", Datatype(.Type, .Type) {
			[ "pair": .Argument($0, const(.Argument($1, const(.End)))) ]
		})

		let first = Declaration("first",
			type: Recur.lambda(.Type, .Type) { A, B in Recur.FunctionType(Pair.ref[A, B], A) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(Pair.ref[A, B]) { pair in pair[A, Recur.lambda(A, B) { a, _ in a }] } })

		let second = Declaration("second",
			type: Recur.lambda(.Type, .Type) { A, B in Recur.FunctionType(Pair.ref[A, B], B) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(Pair.ref[A, B]) { pair in pair[B, Recur.lambda(A, B) { _, b in b }] } })

		return Module("Pair", [ Pair, first, second ])
	}
}


import Prelude
