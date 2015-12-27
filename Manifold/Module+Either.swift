//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var either: Module {
		return Module("Either", [
			Declaration("Either", Datatype(.Type, .Type,
				[
					"left": .Argument(0, .End),
					"right": .Argument(1, .End)
				]
			))
		])
	}
}
