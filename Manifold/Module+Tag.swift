//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var tag: Module {
		let List: Term = "List"
		let cons: Term = "cons"
		let String: Term = "String"
		let Enum = Declaration("Enum",
			type: .Type,
			value: List[String])

		let Tag = Declaration("Tag",
			type: Enum.ref --> .Type,
			value: (Enum.ref, .Type) => { e, Motive in (String --> Motive) --> Motive })

		let here = Declaration("here",
			type: (String, List[String]) => { l, E in Tag.ref[cons[nil, l, E]] },
			value: (String, List[String], .Type) => { s, _, Motive in (String --> Motive) => { f in f[s] }  })

		return Module("Tag", [ list, string ], [ Enum, Tag, here ])
	}
}
