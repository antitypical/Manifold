//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchPair: Module {
		let Pair = Declaration("Pair",
			type: Recur.lambda(.Type, .Type, const(.Type)),
			value: Recur.lambda(.Type, .Type, .Type) { A, B, Result in Recur.lambda(Recur.FunctionType(A, B, Result), const(Result)) })

		let pair = Declaration("pair",
			type: Pair.ref,
			value: Recur.lambda(.Type, .Type, .Type) { A, B, Result in Recur.lambda(A, B, .FunctionType(A, B, Result)) { a, b, f in f[a, b] } })

		let first = Declaration("first",
			type: Recur.lambda(.Type, .Type) { A, B in Recur.FunctionType(Pair.ref[A, B], A) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(Pair.ref[A, B]) { pair in pair[A, Recur.lambda(A, B) { a, _ in a }] } })

		return Module("ChurchPair", [ Pair, pair, first ])
	}
}


import Prelude
