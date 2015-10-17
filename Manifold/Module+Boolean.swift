//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var boolean: Module {
		return Module([
			.Datatype("Boolean", [
				"true": .End,
				"false": .End
			])
		])
	}
}


import Prelude
