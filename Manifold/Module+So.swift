//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var so: Module {
		let Boolean: Recur = "Boolean"
		let So = Declaration("So",
			type: Boolean --> .Type,
			value: Boolean --> .Type)

		let `true`: Recur = "true"
		let Oh = Declaration("Oh",
			type: So.ref[`true`],
			value: .Type)

		return Module("So", [ boolean ], [ So, Oh ])
	}
}


import Prelude
