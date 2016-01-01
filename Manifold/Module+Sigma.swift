//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var sigma: Module {
		let Sigma = Declaration("Sigma", Datatype("A", .Type,
			Datatype.Argument("B", "A" --> .Type,
				[ "sigma": Telescope.Argument("a", "A", .Argument("b", ("B" as Term)["a" as Term], .End)) ]
			)
		))

		let first = Declaration("first",
			type: nil => { A in (A --> .Type) => { B in Sigma.ref[A, B] --> A } },
			value: nil => { A in nil => { B in nil => { v in v[A, nil => { x in B[x] => const(x) }] } } })

		let second = Declaration("second",
			type: nil => { A in (A --> .Type) => { B in Sigma.ref[A, B] => { v in B[first.ref[A, B, v]] } } },
			value: nil => { A in nil => { B in nil => { v in v[nil, nil => { x in B[x] => id }] } } })

		return Module("Sigma", [ Sigma, first, second ])
	}
}


import Prelude
