//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var functor: Module {
		let Functor = Declaration("Functor", Datatype(.Type --> .Type, { f in
			[ "functor": Telescope.Argument((.Type, .Type) => { A, B in (A --> B) --> f[A] --> f[B] }, const(.End)) ]
		}))

		return Module("Functor", [ Functor ])
	}
}


import Prelude
