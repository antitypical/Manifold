//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Recur = "Natural"
		let FiniteSet: Recur = "FiniteSet"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: Natural => { n in n[.Type, .Type => { $0 --> $0 }, (Natural, .Type) => { (n: Recur, A) in A --> (FiniteSet[n] --> A) --> A }] })

		let successor: Recur = "successor"
		let zeroth = Declaration("zeroth",
			type: Natural => { (n: Recur) in FiniteSet[successor[n]] },
			value: Natural => { (n: Recur) in .Type => { (A: Recur) in A => { (FiniteSet[n] --> A) --> $0 } } })

		let nextth = Declaration("nextth",
			type: Natural => { (n: Recur) in FiniteSet[n] --> FiniteSet[successor[n]] },
			value: Natural => { (n: Recur) in (FiniteSet[n], .Type) => { (prev: Recur, A) in A --> (FiniteSet[n] --> A) => { $0[prev] } } })

		return Module("FiniteSet", [ natural ], [ finiteSet, zeroth, nextth ])
	}
}


import Prelude
