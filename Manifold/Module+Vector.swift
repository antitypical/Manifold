//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var vector: Module {
		let Natural: Recur = "Natural"
		let Vector: Recur = "Vector"
		let vector = Declaration("Vector",
			type: .Type --> Natural --> .Type,
			value: (.Type, Natural, .Type) => { A, n, B in (A --> Vector[A, n] --> B) --> B --> B })

		let successor: Recur = "successor"
		let cons = Declaration("cons",
			type: (.Type, Natural)  => { A, n in A --> Vector[A, n] --> Vector[A, successor[n]] },
			value: (.Type, Natural) => { (A: Recur, n) in (A, Vector[A, n], .Type) => { head, tail, B in (A --> Vector[A, successor[n]] --> B, B) => { ifCons, _ in ifCons[head, tail] } } })

		let zero: Recur = "zero"
		let `nil` = Declaration("nil",
			type: .Type => { (A: Recur) in Vector[A, zero] },
			value: (.Type, Natural, .Type) => { A, n, B in ((A --> Vector[A, n] --> B), B) => { _, other in other } })

		return Module("Vector", [ natural ], [ vector, cons, `nil` ])
	}
}
