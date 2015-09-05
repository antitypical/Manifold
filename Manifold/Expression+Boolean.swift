//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var boolean: Module<Recur> {
		let Boolean = Declaration("Boolean",
			type: .Type(0),
			value: lambda(.Type) { A in Recur.lambda(A, A, const(A)) })

		let `true` = Declaration("true",
			type: Boolean.ref.out,
			value: lambda(.Type) { A in Recur.lambda(A, A) { a, _ in a } })

		let `false` = Declaration("false",
			type: Boolean.ref.out,
			value: lambda(.Type) { A in Recur.lambda(A, A) { _, a in a } })

		let not = Declaration("not",
			type: FunctionType(Boolean.ref, Boolean.ref),
			value: lambda(Boolean.ref, .Type) { b, A in Recur.lambda(A, A) { t, f in b[A, f, t] } })

		let `if` = Declaration("if",
			type: lambda(.Type, Boolean.ref) { t, _ in .FunctionType(t, t, t) },
			value: lambda(.Type, Boolean.ref) { t, condition in Recur.lambda(t, t) { condition[$0, $1] } })

		return Module([ Boolean, `true`, `false`, not, `if` ])
	}
}


import Prelude
