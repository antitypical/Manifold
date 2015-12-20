//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var sigma: Module {
		let Sigma = Declaration("Sigma", Datatype(.Type, { A in
			Datatype.Argument(A --> .Type) { B in
				[ "sigma": Telescope.Argument(A) { a in .Argument(B[a], const(.End)) } ]
			}
		}))

		let first = Declaration("first",
			type: () => { A in (A --> .Type) => { B in Sigma.ref[A, B] --> A } },
			value: () => { A in () => { B in () => { v in v[A, () => { x in B[x] => const(x) }] } } })

		let second = Declaration("second",
			type: () => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in B[first.ref[A, B, v]] } } },
			value: () => { A in () => { B in () => { v in v[B[first.ref[A, B, v]], () => { x in B[x] => id }] } } })

		return Module("Sigma", [ Sigma, first, second ])
	}
}


import Prelude
