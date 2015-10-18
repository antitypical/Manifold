//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var prelude: Module {
		let identity = Declaration("identity",
			type: Recur.lambda(.Type) { A in Recur.FunctionType(A, A) },
			value: Recur.lambda(.Type) { A in Recur.lambda(A, id) })

		return Module("Prelude", [ identity ])
	}
}


import Prelude
