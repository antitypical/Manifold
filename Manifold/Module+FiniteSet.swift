//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Recur = "Natural"
		let FiniteSet: Recur = "FiniteSet"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: (Natural, .Type) => { n, A in n[.Type, A --> A, Natural => { (n: Recur) in (FiniteSet[n] --> A) --> A }] })

		return Module("FiniteSet", [ natural ], [ finiteSet ])
	}
}
