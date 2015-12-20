//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Term = "Natural"
		let Vector: Term = "Vector"
		let vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: (nil, nil) => { A, n in .Type => { B in n[nil, B --> B, Natural => { n in (A --> Vector[A, n] --> B) --> B }] } })

		let successor: Term = "successor"
		let cons = Declaration("cons",
			type: (nil, Natural)  => { A, n in A --> Vector[A, n] --> Vector[A, successor[n]] },
			value: (nil, nil) => { A, n in (nil, nil, nil) => { head, tail, B in (A --> Vector[A, n] --> B) => { ifCons in ifCons[head, tail] } } })

		let zero: Term = "zero"
		let `nil` = Declaration("nil",
			type: nil => { A in Vector[A, zero] },
			value: (nil, nil) => { A, B in B => id })

		return Module("Vector", [ natural ], [ vector, cons, `nil` ])
	}
}


import Prelude
