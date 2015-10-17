//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var unit: Module<Recur> {
		return Module([
			.Datatype("Unit", [ "unit": .End ]),
		])
	}
}
