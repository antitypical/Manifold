//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchPair: Module {
		let pair = Declaration("pair",
			type: Recur.lambda(.Type, .Type, .Type) { A, B, Result in Recur.lambda(A, B, Recur.FunctionType(A, B, Result), const(Result)) },
			value: Recur.lambda(.Type, .Type, .Type) { A, B, Result in Recur.lambda(A, B, .FunctionType(A, B, Result)) { a, b, f in f[a, b] } })

		return Module([ churchBoolean ], [ pair ])
	}
}


import Prelude
