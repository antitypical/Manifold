//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchSigma: Module {
		let Sigma = Declaration("Sigma",
			type: Recur.lambda(.Type) { A in .FunctionType(.FunctionType(A, .Type), .Type) },
			value: Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, .Type), .Type) { B, C in Recur.FunctionType(Recur.lambda(A) { x in .FunctionType(B[x], C) }, C) } })

		let sigma = Declaration("sigma",
			type: Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, .Type), A) { B, x in .FunctionType(B[x], Sigma.ref[A, Recur.lambda(A) { B[$0] }]) } },
			value: Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, .Type), A) { B, x in Recur.lambda(B[x], .Type) { y, C in Recur.lambda(Recur.lambda(A) { xʹ in .FunctionType(B[xʹ], C) }) { f in f[x, y] } } } })

		let first = Declaration("first",
			type: Recur.lambda(.Type) { A in Recur.lambda(A --> .Type) { B in Sigma.ref[A, Recur.lambda(A) { x in B[x] }] --> A } },
			value: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, A => { x in B[x] }] => { v in v[A, A => { x in B[x] => const(x) }] } } })

		return Module("ChurchSigma", [ Sigma, sigma, first ])
	}
}


import Prelude
