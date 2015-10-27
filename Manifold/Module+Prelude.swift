//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var prelude: Module {
		let identity = Declaration("identity",
			type: Term.lambda(.Type) { A in A --> A },
			value: Term.lambda(.Type) { A in Term.lambda(A, id) })

		let constant = Declaration("constant",
			type: Term.lambda(.Type, .Type) { A, B in A --> B --> A },
			value: Term.lambda(.Type, .Type) { A, B in Term.lambda(A) { Term.lambda(B, const($0)) } })

		let flip = Declaration("flip",
			type: Term.lambda(.Type, .Type, .Type) { A, B, C in ((A --> B --> C) --> (B --> A --> C)) },
			value: Term.lambda(.Type, .Type, .Type) { A, B, C in Term.lambda((A --> B --> C)) { f in Term.lambda(B, A) { b, a in f[a, b] } } })

		return Module("Prelude", [ identity, constant, flip ])
	}
}


import Prelude
