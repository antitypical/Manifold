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
			type: List[String] => { E in (Tag.ref[E] --> .Type) --> .Type },
			value: nil => { E in nil => { P in E[nil, (nil, nil) => { l, E in Pair[P[here.ref[nil, nil]], Branches[E, nil => { t in P[there.ref[nil, nil, t]] }]] }, Unit] } })

		let _case: Term = "case"
		let first: Term = "first"
		let second: Term = "second"
		let `case` = Declaration("case",
			type: List[String] => { E in (Tag.ref[E] --> .Type) => { P in Branches[E, P] --> Tag.ref[E] => { t in P[t] } } },
			value: nil => { E in nil => { P in (nil, nil) => { cs, t in t[nil, nil => { _ in first[nil, nil, cs] }, nil => { t in _case[E, nil => { t in P[E, there.ref[nil, nil, t]] }, second[nil, nil, cs], t] }] } } })


		return Module("Tag", [ list, string, unit, pair ], [ Enum, Tag, here, there, branches, `case` ])
	}
}
