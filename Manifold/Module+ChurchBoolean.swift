//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchBoolean: Module {
		let Boolean = Declaration("Boolean",
			type: .Type,
			value: Recur.lambda(.Type) { Recur.lambda($0, $0, const($0)) })

		let `true` = Declaration("true",
			type: Boolean.ref,
			value: Recur.lambda(.Type) { A in Recur.lambda(A, A) { a, _ in a } })

		let `false` = Declaration("false",
			type: Boolean.ref,
			value: Recur.lambda(.Type) { A in Recur.lambda(A, A) { _, b in b } })

		let not = Declaration("not",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, .Type) { b, A in Recur.lambda(A, A) { t, f in b[A, f, t] } })

		let `if` = Declaration("if",
			type: Recur.lambda(.Type, Boolean.ref) { A, condition in Recur.lambda(A, A, const(A)) },
			value: Recur.lambda(.Type, Boolean.ref) { A, condition in Recur.lambda(A, A) { condition[A, $0, $1] } })

		let and = Declaration("and",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, q, `false`.ref] })

		let or = Declaration("or",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref) { p, q in p[Boolean.ref, `true`.ref, q] })

		let xor = Declaration("xor",
			type: Recur.FunctionType(Boolean.ref, Boolean.ref, Boolean.ref),
			value: Recur.lambda(Boolean.ref, Boolean.ref, { p, q in p[Boolean.ref, not.ref[q], q] }))

		return Module("ChurchBoolean", [ Boolean, `true`, `false`, not, `if`, and, or, xor ])
	}
}


import Prelude
