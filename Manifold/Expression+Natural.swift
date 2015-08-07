//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var natural: Module<Recur> {
		// Natural : Type
		// Natural = λ tag : Boolean . if tag then Natural else Unit
		let Natural = Declaration("Natural",
			type: .Type(0),
			value: lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A, const(A)) })

		// zero : Natural
		// zero = (false, ()) : Natural
		let zero = Declaration("zero",
			type: "Natural",
			value: lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in s } })

		// successor : Natural -> Natural
		// successor = λ n : Natural . (true, n) : Natural
		let successor = Declaration("successor",
			type: FunctionType(Recur("Natural"), Recur("Natural")),
			value: lambda(Recur("Natural")) { n in Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in f[n[A, f, s]] } } })

		return Module([ Natural, zero, successor ])
	}
}


import Prelude
