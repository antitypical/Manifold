//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchPair: Module {
		let Pair = Declaration("Pair",
			type: Recur.lambda(.Type, .Type, const(.Type)),
			value: Recur.lambda(.Type, .Type, .Type) { A, B, Result in .lambda(.FunctionType(A, B, Result), const(Result)) })

		let pair = Declaration("pair",
			type: Recur.lambda(.Type, .Type) { A, B in .FunctionType(A, B, Pair.ref[A, B]) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(A, B, .Type) { a, b, Result in Recur.lambda(.FunctionType(A, B, Result)) { f in f[a, b] } } })

		let first = Declaration("first",
			type: Recur.lambda(.Type, .Type) { A, B in Recur.FunctionType(Pair.ref[A, B], A) },
			value: Recur.lambda(.Type, .Type) { A, B in Recur.lambda(Pair.ref[A, B]) { pair in pair[A, Recur.lambda(A, B) { a, _ in a }] } })

		return Module("ChurchPair", [ Pair, pair, first ])
	}
}


import Prelude
