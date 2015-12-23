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
			value: (Enum.ref, .Type) => { e, Motive in (String --> Motive) --> (List[String] --> Motive) --> Motive })

		let here = Declaration("here",
			type: (String, List[String]) => { l, E in Tag.ref[cons[nil, l, E]] },
			value: (String, List[String], .Type) => { l, _, Motive in (String --> Motive, List[String] --> Motive) => { f, _ in f[l] }  })

		let there = Declaration("there",
			type: (String, List[String]) => { l, E in Tag.ref[E] --> Tag.ref[cons[nil, l, E]] },
			value: (String, List[String]) => { _, E in Tag.ref[E] --> .Type => { Motive in (String --> Motive, List[String] --> Motive) => { _, f in f[E] } } })

		let Unit: Term = "Unit"
		let Pair: Term = "Pair"
		let Branches: Term = "Branches"
		let branches = Declaration("Branches",
			type: Enum.ref => { E in (Tag.ref[E] --> .Type) --> .Type },
			value: nil => { E in nil => { P in E[nil, (nil, nil) => { l, E in Pair[P[here.ref[nil, nil]], Branches[E, nil => { t in P[there.ref[nil, nil, t]] }]] }, Unit] } })

		return Module("Tag", [ list, string, unit, pair ], [ Enum, Tag, here, there, branches ])
	}
}
