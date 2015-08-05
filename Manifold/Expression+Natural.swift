//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var natural: Module<Recur> {
		// Natural : Type
		// Natural = λ tag : Boolean . if tag then Natural else Unit
		let Natural = Declaration("Natural",
			lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A, const(A)) },
			.Type(0))

		// zero : Natural
		// zero = (false, ()) : Natural
		let zero = Declaration("zero",
			lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in s } },
			"Natural")

		// successor : Natural -> Natural
		// successor = λ n : Natural . (true, n) : Natural
		let successor = Declaration("successor",
			lambda(Recur("Natural")) { n in Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in f[n[A, f, s]] } } },
			FunctionType(Recur("Natural"), Recur("Natural")))

		return Module([ Natural, zero, successor ])
	}
}


import Prelude
