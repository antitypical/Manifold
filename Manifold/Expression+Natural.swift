//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var natural: Module<Recur> {
		// Natural : Type
		// Natural = λ A : Type . λ f : A -> A . λ a : A . A
		let Natural = Declaration("Natural",
			type: .Type(0),
			value: lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A, const(A)) })

		// zero : Natural
		// zero = λ A : Type . λ f : A -> A . λ a : A . a
		let zero = Declaration("zero",
			type: "Natural",
			value: lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in s } })

		// successor : Natural -> Natural
		// successor = λ n : Natural . λ A : Type . λ f : A -> A . λ a : A . f (n A f s)
		let successor = Declaration("successor",
			type: FunctionType(Recur("Natural"), Recur("Natural")),
			value: lambda(Recur("Natural")) { n in Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, A), A) { f, s in f[n[A, f, s]] } } })

		return Module([ Natural, zero, successor ])
	}
}


import Prelude
