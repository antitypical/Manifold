//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var sigma: Module {
		let Sigma = Declaration("Sigma", Datatype(.Type,
			Datatype.Argument(0 --> .Type,
				[ "sigma": Telescope.Argument(0, .Argument((1 as Term)[2 as Term], .End)) ]
			)
		))

		let first = Declaration("first",
			type: nil => { A in (A --> .Type) => { B in Sigma.ref[A, B] --> A } },
			value: nil => { A in nil => { B in nil => { v in v[nil, nil => { x in B[x] => const(x) }] } } })

		let second = Declaration("second",
			type: nil => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in B[first.ref[A, B, v]] } } },
			value: nil => { A in nil => { B in nil => { v in v[nil, nil => { x in B[x] => id }] } } })

		return Module("Sigma", [ Sigma, first, second ])
	}
}


import Prelude
