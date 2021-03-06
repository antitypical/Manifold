//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var functor: Module {
		let Functor = Declaration("Functor", Datatype("fmap", .Type --> .Type,
			[ "functor": Telescope.Argument("a", (.Type, .Type) => { A, B in (A --> B) --> (0 as Term)[A] --> (0 as Term)[B] }, .End) ]
		))

		let map = Declaration("map",
			type: .Type --> nil => { f in (Functor.ref[f], .Type, .Type) => { F, A, B in (A --> B) --> f[A] --> f[B] } },
			value: nil => { f in (nil, nil, nil) => { F, A, B in (A --> B, f[A]) => { transform, functor in F[nil, nil, functor] } } })

		return Module("Functor", [ Functor, map ])
	}
}
