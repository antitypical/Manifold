//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchEither: Module {
		let Either = Declaration("Either",
			type: Recur.FunctionType(.Type, .Type, .Type),
			value: Recur.lambda(.Type, .Type, .Type) { L, R, Result in Recur.FunctionType(.FunctionType(L, Result), .FunctionType(R, Result), Result) })

		let left = Declaration("left",
			type: Recur.lambda(.Type, .Type) { L, R in .FunctionType(L, Either.ref[L, R]) },
			value: Recur.lambda(.Type, .Type) { L, R in Recur.lambda(L, .Type) { l, Result in Recur.lambda(.FunctionType(L, Result), .FunctionType(R, Result)) { ifL, _ in ifL[l] } } })

		return Module("ChurchEither", [ Either, left ])
	}
}
