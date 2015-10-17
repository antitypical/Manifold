//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var maybe: Module {
		return Module([
			Declaration.Datatype("Maybe", .Argument(.Type, {
				[
					"just": .Argument($0, const(.End)),
					"nothing": .End
				]
			}))
		])
	}
}


import Prelude
