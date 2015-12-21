//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var datatype: Module {
		let _Datatype: Term = "Datatype"
		let datatype = Declaration("Datatype", Datatype(.Type) { I in
			[
				"end": .Argument(I, const(.End)),
				"recursive": .Argument(I, const(.Recursive(.End))),
				"argument": Telescope.Argument(.Type) { A in .Argument(A --> _Datatype[I], const(.End)) },
			]
		})

		let μ = Declaration("μ",
			type: nil => { I in _Datatype[I] --> I --> .Type },
			value: nil => { I in (_Datatype[I], I, .Type) => { _, _, Motive in (_Datatype[I] --> I --> Motive) --> Motive } })

		let ISet = Declaration("ISet",
			type: .Type --> .Type(1),
			value: .Type => { I in I --> .Type })

		let El: Term = "El"
		let `init` = Declaration("init",
			type: nil => { I in (_Datatype[I], I) => { D, i in El[D, μ.ref[D], i] --> μ.ref[D, i] } },
			value: nil)

		return Module("Datatype", [ tag ], [ datatype, μ, `init`, ISet ])
	}
}


import Prelude
