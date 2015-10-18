//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchBoolean: Module {
		let Boolean = Declaration("Boolean",
			type: .Type,
			value: Recur.lambda(.Type) { Recur.lambda($0, $0, const($0)) })

		let `true` = Declaration("true",
			type: Boolean.ref,
			value: Recur.lambda(.Type) { A in Recur.lambda(A, A, { a, _ in a }) })

		let `false` = Declaration("false",
			type: Boolean.ref,
			value: Recur.lambda(.Type) { A in Recur.lambda(A, A, { _, b in b }) })

		return Module([ Boolean, `true`, `false` ])
	}
}


import Prelude
