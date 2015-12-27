//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var functor: Module {
		let Functor = Declaration("Functor", Datatype(.Type --> .Type, { f in
			[ "functor": Telescope.Argument(nil, (.Type, .Type) => { A, B in (A --> B) --> f[A] --> f[B] }, .End) ]
		}))

		let map = Declaration("map",
			type: .Type --> nil => { f in (Functor.ref[f], .Type, .Type) => { F, A, B in (A --> B) --> f[A] --> f[B] } },
			value: nil => { f in (nil, nil, nil) => { F, A, B in (A --> B, f[A]) => { transform, functor in F[nil, nil, functor] } } })

		return Module("Functor", [ Functor, map ])
	}
}
