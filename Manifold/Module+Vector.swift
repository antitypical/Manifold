//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Term = "Natural"
		let Vector: Term = "Vector"
		let vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: () => { A, n in .Type => { B in n[.Type, B --> B, Natural => { n in (A --> Vector[A, n] --> B) --> B }] } })

		let successor: Term = "successor"
		let cons = Declaration("cons",
			type: (.Type, Natural)  => { A, n in A --> Vector[A, n] --> Vector[A, successor[n]] },
			value: () => { A, n in () => { head, tail, B in (A --> Vector[A, n] --> B) => { ifCons in ifCons[head, tail] } } })

		let zero: Term = "zero"
		let `nil` = Declaration("nil",
			type: () => { A in Vector[A, zero] },
			value: () => { A, B in B => id })

		return Module("Vector", [ natural ], [ vector, cons, `nil` ])
	}
}


import Prelude
