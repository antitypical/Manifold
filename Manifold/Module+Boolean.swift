//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var boolean: Module {
		let Boolean = Declaration<Term>.Datatype("Boolean", [
			"true": .End,
			"false": .End
		])

		let `true`: Term = "true"
		let `false`: Term = "false"

		let not = Declaration("not",
			type: Boolean.ref --> Boolean.ref,
			value: Term.lambda(Boolean.ref, .Type) { b, A in Term.lambda(A, A) { t, f in b[A, f, t] } })

		let `if` = Declaration("if",
			type: Term.lambda(.Type, Boolean.ref) { A, condition in Term.lambda(A, A, const(A)) },
			value: Term.lambda(.Type, Boolean.ref) { A, condition in Term.lambda(A, A) { condition[A, $0, $1] } })

		let and = Declaration("and",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: Term.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, q, `false`] })

		let or = Declaration("or",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: Term.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, `true`, q] })

		let xor = Declaration("xor",
			type: Boolean.ref --> Boolean.ref --> Boolean.ref,
			value: Term.lambda(Boolean.ref, Boolean.ref, { p, q in p[Boolean.ref, not.ref[q], q] }))

		return Module("Boolean", [ Boolean, not, `if`, and, or, xor ])
	}
}


import Prelude
