//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchSigma: Module {
		let Sigma = Declaration<Recur>("Sigma",
			type: .Type => { A in (A --> .Type) --> .Type },
			value: .Type => { A in (A --> .Type, .Type) => { B, C in (A => { x in B[x] --> C }) --> C } })

		let sigma = Declaration("sigma",
			type: .Type => { A in (A --> .Type, A) => { (B, x: Recur) in B[x] --> Sigma.ref[A, B] } },
			value: .Type => { A in (A --> .Type, A) => { B, x in (B[x], .Type) => { y, C in (A => { xʹ in B[xʹ] --> C }) => { f in f[x, y] } } } })

		let first = Declaration("first",
			type: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] --> A } },
			value: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in v[A, A => { (x: Recur) in B[x] => const(x) }] } } })

		let second = Declaration("second",
			type: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in B[first.ref[A, B, v]] } } },
			value: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in v[B[first.ref[A, B, v]], A => { (x: Recur) in B[x] => id }] } } })

		return Module("ChurchSigma", [ Sigma, sigma, first, second ])
	}
}


import Prelude
