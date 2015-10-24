//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var sigma: Module {
		let Sigma = Declaration<Recur>.Datatype("Sigma", Datatype.Argument(.Type, { A in
			Datatype.Argument(A --> .Type) { B in
				[ "sigma": Telescope.Argument(A) { a in .Argument(B[a], const(.End)) } ]
			}
		}))

		let first = Declaration("first",
			type: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] --> A } },
			value: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in v[A, A => { (x: Recur) in B[x] => const(x) }] } } })

		let second = Declaration("second",
			type: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in B[first.ref[A, B, v]] } } },
			value: .Type => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in v[(A => { (x: Recur) in B[x] })[first.ref[A, B, v]], A => { (x: Recur) in B[x] => id }] } } })

		return Module("Sigma", [ Sigma, first, second ])
	}
}


import Prelude
