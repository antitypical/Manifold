//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var boolean: Module<Recur> {
		let Boolean = Binding("Boolean",
			lambda(.Type) { A in Recur.lambda(A, A, const(A)) },
			.Type(0))
		let `true` = Binding("true",
			lambda(.Type) { A in Recur.lambda(A, A) { a, _ in a } },
			"Boolean")
		let `false` = Binding("false",
			lambda(.Type) { A in Recur.lambda(A, A) { _, a in a } },
			"Boolean")

		return Module([ Boolean, `true`, `false` ])
	}
}


import Prelude
