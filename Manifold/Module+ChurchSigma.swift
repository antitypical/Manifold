//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchSigma: Module {
		let Sigma = Declaration("Sigma",
			type: Recur.lambda(.Type) { A in .FunctionType(.FunctionType(A, .Type), .Type) },
			value: Recur.lambda(.Type) { A in Recur.lambda(.FunctionType(A, .Type), .Type) { B, C in Recur.FunctionType(Recur.lambda(A) { x in .FunctionType(B[x], C) }, C) } })

		return Module("ChurchSigma", [ Sigma ])
	}
}
