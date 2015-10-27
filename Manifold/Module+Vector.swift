//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Term = "Natural"
		let Vector: Term = "Vector"
		let vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: (.Type, Natural, .Type) => { A, n, B in n[.Type, B --> B, Natural => { n in (A --> Vector[A, n] --> B) --> B }] })

		let successor: Term = "successor"
		let cons = Declaration("cons",
			type: (.Type, Natural)  => { A, n in A --> Vector[A, n] --> Vector[A, successor[n]] },
			value: (.Type, Natural) => { (A: Term, n) in (A, Vector[A, n], .Type) => { head, tail, B in (A --> Vector[A, n] --> B) => { ifCons in ifCons[head, tail] } } })

		let zero: Term = "zero"
		let `nil` = Declaration("nil",
			type: .Type => { (A: Term) in Vector[A, zero] },
			value: (.Type, .Type) => { A, B in B => id })

		return Module("Vector", [ natural ], [ vector, cons, `nil` ])
	}
}


import Prelude
