//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var natural: Module<Recur> {
		return Module([
			.Datatype("Natural", [
				"zero": .End,
				"successor": .Recursive(.End)
			])
		])
	}
}


import Prelude
