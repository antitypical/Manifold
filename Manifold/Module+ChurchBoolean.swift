//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchBoolean: Module {
		let Boolean = Declaration("Boolean",
			type: .Type,
			value: Recur.lambda(.Type) { Recur.lambda($0, $0, const($0)) })

		return Module([ Boolean ])
	}
}


import Prelude
