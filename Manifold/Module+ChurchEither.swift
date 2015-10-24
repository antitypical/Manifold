//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchEither: Module {
		let Either = Declaration<Recur>("Either",
			type: .Type --> .Type --> .Type,
			value: (.Type, .Type, .Type) => { L, R, Result in (L --> Result) --> (R --> Result) --> Result })

		let left = Declaration("left",
			type: (.Type, .Type) => { L, R in L --> Either.ref[L, R] },
			value: (.Type, .Type) => { L, R in (L, .Type) => { (l: Recur, Result) in ((L --> Result), (R --> Result)) => { ifL, _ in ifL[l] } } })

		let right = Declaration("right",
			type: (.Type, .Type) => { L, R in R --> Either.ref[L, R] },
			value: (.Type, .Type) => { L, R in (R, .Type) => { (r: Recur, Result) in ((L --> Result), (R --> Result)) => { _, ifR in ifR[r] } } })

		return Module("ChurchEither", [ Either, left, right ])
	}
}
