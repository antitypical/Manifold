//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Term = "Natural"
		let FiniteSet: Term = "FiniteSet"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: () => { n in n[.Type, .Type => { $0 --> $0 }, (Natural, .Type) => { n, A in A --> (FiniteSet[n] --> A) --> A }] })

		let successor: Term = "successor"
		let zeroth = Declaration("zeroth",
			type: Natural => { n in FiniteSet[successor[n]] },
			value: () => { n in () => { A in () => { (FiniteSet[n] --> A) --> $0 } } })

		let nextth = Declaration("nextth",
			type: Natural => { n in FiniteSet[n] --> FiniteSet[successor[n]] },
			value: () => { n in (FiniteSet[n], nil) => { prev, A in A --> () => { $0[prev] } } })

		return Module("FiniteSet", [ natural ], [ finiteSet, zeroth, nextth ])
	}
}


import Prelude
