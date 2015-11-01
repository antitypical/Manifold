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
			value: () => { b, A in () => { t, f in b[A, f, t] } })

		let `if` = Declaration("if",
			type: (.Type, Boolean.ref) => { A, condition in (A, A) => const(A) },
			value: () => { A, condition in () => { condition[A, $0, $1] } })

		let and = Declaration("and",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: () => { p, q in p[Boolean.ref, q, `false`] })

		let or = Declaration("or",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: () => { p, q in p[Boolean.ref, `true`, q] })

		let xor = Declaration("xor",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: () => { p, q in p[Boolean.ref, not.ref[q], q] })

		return Module("Boolean", [ Boolean, not, `if`, and, or, xor ])
	}
}


import Prelude
