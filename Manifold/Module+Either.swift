//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var either: Module {
		return Module("Either", [
			Declaration("Either", .Type, .Type) {
				[
					"left": .Argument($0, const(.End)),
					"right": .Argument($1, const(.End))
				]
			}
		])
	}
}


import Prelude
