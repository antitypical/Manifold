//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var list: Module {
		return Module("List", [
			Declaration("List", .Type) {
				[
					"cons": .Argument($0, const(.Recursive(.End))),
					"nil": .End
				]
			}
		])
	}
}


import Prelude
