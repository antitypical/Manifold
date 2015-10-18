//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var unit: Module {
		return Module("Unit", [
			.Datatype("Unit", [ "unit": .End ]),
		])
	}
}
