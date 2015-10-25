//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Recur = "Natural"
		let FiniteSet: Recur = "FiniteSet"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: (Natural, .Type) => { n, A in n[.Type, A --> A, Natural => { (n: Recur) in (FiniteSet[n] --> A) --> A }] })

		let successor: Recur = "successor"
		let zeroth = Declaration("zeroth",
			type: Natural => { (n: Recur) in FiniteSet[successor[n]] },
			value: .Type => { A in A => id })

		let nextth = Declaration("nextth",
			type: Natural => { (n: Recur) in FiniteSet[n] --> FiniteSet[successor[n]] },
			value: (Natural, .Type) => { (n: Recur, A) in FiniteSet[n] => { (a: Recur) in (FiniteSet[n] --> A) => { $0[a] } } })

		return Module("FiniteSet", [ natural ], [ finiteSet, zeroth, nextth ])
	}
}


import Prelude
