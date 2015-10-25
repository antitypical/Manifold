//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var finiteSet: Module {
		let Natural: Recur = "Natural"
		let finiteSet = Declaration("FiniteSet",
			type: Natural --> .Type,
			value: .Type)

		return Module("FiniteSet", [ natural ], [ finiteSet ])
	}
}
