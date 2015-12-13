//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var datatype: Module {
		return Module("Datatype", [
			Declaration("Datatype", Datatype(.Type) { I in
				[
					"end": .Argument(I, const(.End)),
					"recursive": .Argument(I, const(.Recursive(.End))),
				]
			})
		])
	}
}


import Prelude
