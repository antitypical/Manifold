//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var string: Module {
		let String = Declaration("String",
			type: .Type,
			value: .Embedded(Swift.String.self))

		return Module("String", [ String ])
	}
}
