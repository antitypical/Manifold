//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchEither: Module {
		let Either = Declaration("Either",
			type: Recur.FunctionType(.Type, .Type, .Type),
			value: Recur.lambda(.Type, .Type, .Type) { L, R, Result in Recur.FunctionType(.FunctionType(L, Result), .FunctionType(R, Result), Result) })

		return Module("ChurchEither", [ Either ])
	}
}
