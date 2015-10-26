//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var prelude: Module {
		let identity = Declaration("identity",
			type: Recur.lambda(.Type) { A in A --> A },
			value: Recur.lambda(.Type) { A in Recur.lambda(A, id) })

		let constant = Declaration("constant",
			type: Recur.lambda(.Type, .Type) { A, B in A --> B --> A },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(A) { Recur.lambda(B, const($0)) } })

		let flip = Declaration("flip",
			type: Recur.lambda(.Type, .Type, .Type) { A, B, C in ((A --> B --> C) --> (B --> A --> C)) },
			value: Recur.lambda(.Type, .Type, .Type) { A, B, C in Recur.lambda((A --> B --> C)) { f in Recur.lambda(B, A) { b, a in f[a, b] } } })

		return Module("Prelude", [ identity, constant, flip ])
	}
}


import Prelude
