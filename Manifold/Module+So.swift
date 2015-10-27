//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var so: Module {
		let Boolean: Recur = "Boolean"
		let So = Declaration("So",
			type: Boolean --> .Type,
			value: Boolean => { b in b[.Type, .Type => { $0 --> $0 }, .Type => { $0 --> $0 }] })

		return Module("So", [ boolean ], [ So ])
	}
}
