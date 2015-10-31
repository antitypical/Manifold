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
		let listMap: Term = "List.map"
		let map = Declaration("List.map",
			type: (.Type, .Type) => { A, B in (A --> B) --> List.ref[A] --> List.ref[B] },
			value: { A, B, transform, list in list[List.ref[B], () => { cons[B, transform[$0], listMap[A, B, transform, $1]] }, `nil`[B]] })

		let pure = Declaration("List.pure",
			type: .Type => { A in A --> List.ref[A] },
			value: .Type)

		let bind = Declaration("List.bind",
			type: (.Type, .Type) => { A, B in (A --> List.ref[B]) --> List.ref[A] --> List.ref[B] },
			value: .Type)

		return Module("List", [ List, map, pure, bind ])
	}
}


import Prelude
