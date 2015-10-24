//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Recur = "Natural"
		let Vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: (.Type, Natural) => { _ in .Type })

		return Module("Vector", [ natural ], [ Vector ])
	}
}
