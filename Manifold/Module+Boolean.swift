//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var boolean: Module {
		let Boolean = Declaration.Datatype("Boolean", [
			"true": .End,
			"false": .End
		])

		let `true`: Term = "true"
		let `false`: Term = "false"

		let not = Declaration("not",
			type: Boolean.ref --> Boolean.ref,
			value: (nil, nil, nil, nil) => { b, A, t, f in b[A, f, t] })

		let `if` = Declaration("if",
			type: (.Type, Boolean.ref) => { A, condition in (A, A) => const(A) },
			value: (nil, nil, nil, nil) => { A, condition, then, `else` in condition[A, then, `else`] })

		let and = Declaration("and",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: (nil, nil) => { p, q in p[nil, q, `false`] })

		let or = Declaration("or",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: (nil, nil) => { p, q in p[nil, `true`, q] })

		let xor = Declaration("xor",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: (nil, nil) => { p, q in p[nil, not.ref[q], q] })

		return Module("Boolean", [ Boolean, not, `if`, and, or, xor ])
	}
}


import Prelude
