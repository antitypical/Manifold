//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var boolean: Module {
		let Boolean = Declaration<Recur>.Datatype("Boolean", [
			"true": .End,
			"false": .End
		])

		let `true`: Recur = "true"
		let `false`: Recur = "false"

		let not = Declaration("not",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, .Type) { b, A in Recur.lambda(A, A) { t, f in b[A, f, t] } })

		let `if` = Declaration("if",
			type: Recur.lambda(.Type, Boolean.ref) { A, condition in Recur.lambda(A, A, const(A)) },
			value: Recur.lambda(.Type, Boolean.ref) { A, condition in Recur.lambda(A, A) { condition[A, $0, $1] } })

		let and = Declaration("and",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, q, `false`] })

		let or = Declaration("or",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, `true`, q] })

		let xor = Declaration("xor",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref, { p, q in p[Boolean.ref, not.ref[q], q] }))

		return Module("Boolean", [ Boolean, not, `if`, and, or, xor ])
	}
}


import Prelude
