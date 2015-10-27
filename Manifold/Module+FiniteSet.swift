//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Term = "Natural"
		let FiniteSet: Term = "FiniteSet"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: Natural => { n in n[.Type, .Type => { $0 --> $0 }, (Natural, .Type) => { (n: Term, A) in A --> (FiniteSet[n] --> A) --> A }] })

		let successor: Term = "successor"
		let zeroth = Declaration("zeroth",
			type: Natural => { (n: Term) in FiniteSet[successor[n]] },
			value: Natural => { (n: Term) in .Type => { (A: Term) in A => { (FiniteSet[n] --> A) --> $0 } } })

		let nextth = Declaration("nextth",
			type: Natural => { (n: Term) in FiniteSet[n] --> FiniteSet[successor[n]] },
			value: Natural => { (n: Term) in (FiniteSet[n], .Type) => { (prev: Term, A) in A --> (FiniteSet[n] --> A) => { $0[prev] } } })

		return Module("FiniteSet", [ natural ], [ finiteSet, zeroth, nextth ])
	}
}


import Prelude
