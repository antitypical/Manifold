//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var either: Module {
		return Module("Either", [
			Declaration("Either", Datatype("L", .Type, "R", .Type,
				[
					"left": .Argument("l", "L", .End),
					"right": .Argument("r", "R", .End)
				]
			))
		])
	}
}
