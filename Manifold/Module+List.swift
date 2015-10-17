//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var list: Module<Recur> {
		return Module([
			Declaration.Datatype("List", .Argument(.Type, {
				[
					"nil": .End,
					"cons": .Argument($0, const(.Recursive(.End)))
				]
			}))
		])
	}
}


import Prelude
