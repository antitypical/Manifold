//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Recur = "Natural"
		let Vector: Recur = "Vector"
		let vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: (.Type, Natural, .Type) => { A, n, B in (A --> Vector[A, n] --> B) --> B --> B })

		return Module("Vector", [ natural ], [ vector ])
	}
}
