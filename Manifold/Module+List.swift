//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var list: Module {
		let List = Declaration("List", Datatype(.Type) {
			[
				"cons": .Argument($0, const(.Recursive(.End))),
				"nil": .End
			]
		})

		let cons: Term = "cons"
		let `nil`: Term = "nil"
		let map = Declaration("List.map",
			type: (.Type, .Type) => { A, B in (A --> B) --> List.ref[A] --> List.ref[B] },
			value: { A, B in (A --> B, nil) => { transform, list in list[List.ref[B], () => { cons[B, transform[$0]] }, `nil`[B]] } })

		return Module("List", [ List, map ])
	}
}


import Prelude
