//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var boolean: Module<Recur> {
		let Boolean = Declaration("Boolean",
			type: .Type(0),
			value: lambda(.Type) { A in Recur.lambda(A, A, const(A)) })
		let `true` = Declaration("true",
			type: "Boolean",
			value: lambda(.Type) { A in Recur.lambda(A, A) { a, _ in a } })
		let `false` = Declaration("false",
			type: "Boolean",
			value: lambda(.Type) { A in Recur.lambda(A, A) { _, a in a } })

		return Module([ Boolean, `true`, `false` ])
	}
}


import Prelude
