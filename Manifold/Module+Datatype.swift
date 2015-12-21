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
		return Module("Datatype", [ tag ], [ datatype ])
	}
}


import Prelude
