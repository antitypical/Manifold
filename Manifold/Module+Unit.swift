//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var unit: Module<Recur> {
		return Module([
			.Datatype("Unit", [ "unit": .End ]),
		])
	}
}
