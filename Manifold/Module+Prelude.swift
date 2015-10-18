//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var prelude: Module {
		let identity = Declaration("identity",
			type: Recur.lambda(.Type) { A in Recur.FunctionType(A, A) },
			value: Recur.lambda(.Type) { A in Recur.lambda(A, id) })

		let constant = Declaration("constant",
			type: Recur.lambda(.Type, .Type) { A, B in Recur.FunctionType(A, B, A) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(A) { Recur.lambda(B, const($0)) } })

		return Module("Prelude", [ identity, constant ])
	}
}


import Prelude
