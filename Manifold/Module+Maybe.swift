//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var maybe: Module {
		let Maybe = Declaration.Datatype("Maybe", .Argument(.Type, {
			[
				"just": .Argument($0, const(.End)),
				"nothing": .End
			]
		}))
		return Module("Maybe", [ Maybe ])
	}
}


import Prelude
