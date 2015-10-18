//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var either: Module {
		return Module([
			Declaration.Datatype("Either", .Argument(.Type, { a in
				.Argument(.Type, { b in
					[
						"left": .Argument(a, const(.End)),
						"right": .Argument(b, const(.End))
					]
				})
			}))
		])
	}
}


import Prelude
