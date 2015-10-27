//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var pair: Module {
		let Pair = Declaration<Term>("Pair", Datatype(.Type, .Type) {
			[ "pair": .Argument($0, const(.Argument($1, const(.End)))) ]
		})

		let first = Declaration("first",
			type: Term.lambda(.Type, .Type) { A, B in Pair.ref[A, B] --> A },
			value: Term.lambda(.Type, .Type) { A, B in Term.lambda(Pair.ref[A, B]) { pair in pair[A, Term.lambda(A, B) { a, _ in a }] } })

		let second = Declaration("second",
			type: Term.lambda(.Type, .Type) { A, B in Pair.ref[A, B] --> B },
			value: Term.lambda(.Type, .Type) { A, B in Term.lambda(Pair.ref[A, B]) { pair in pair[B, Term.lambda(A, B) { _, b in b }] } })

		return Module("Pair", [ Pair, first, second ])
	}
}


import Prelude
