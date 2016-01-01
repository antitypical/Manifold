//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var datatype: Module {
		let _Datatype: Term = "Datatype"
		let datatype = Declaration("Datatype", Datatype("I", .Type,
			[
				"end": .Argument("index", "I", .End),
				"recursive": .Argument("index", "I", .Recursive("recur", .End)),
				"argument": Telescope.Argument("A", .Type, .Argument("telescope", "A" --> _Datatype["I" as Term], .End)),
			]
		))

		let μ = Declaration("μ",
			type: nil => { I in _Datatype[I] --> I --> .Type },
			value: nil => { I in (_Datatype[I], I, .Type) => { _, _, Motive in (_Datatype[I] --> I --> Motive) --> Motive } })

		let IType = Declaration("IType",
			type: .Type --> .Type(1),
			value: .Type => { I in I --> .Type })

		let Identical: Term = "≡"
		let Pair: Term = "Pair"
		let Sigma: Term = "Sigma"
		let El: Term = "El"
		let el = Declaration("El",
			type: .Type => { I in _Datatype[I] --> IType.ref[I] --> IType.ref[I] },
			value: .Type => { I in
				(_Datatype[I], IType.ref[I], I) => { D, X, i in
					D[.Type,
						I => { j in Identical[I, i, j] },
						(I, _Datatype[I]) => { j, D in Pair[X[j], El[I, D, X, i]] },
						.Type => { A in (A --> _Datatype[I]) => { B in Sigma[A, nil => { a in El[I, B[a], X, i] }] } }]
				}
			})

		let `init` = Declaration("init",
			type: nil => { I in (_Datatype[I], I) => { D, i in El[I, D, μ.ref[I, D], i] --> μ.ref[I, D, i] } },
			value: nil => { I in (nil, nil) => { D, i in nil => { _ in nil } } })

		return Module("Datatype", [ tag, propositionalEquality, pair, sigma ], [ datatype, μ, `init`, IType, el ])
	}
}


import Prelude
