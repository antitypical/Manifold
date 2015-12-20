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
		let _map: Term = "List.map"
		let map = Declaration("List.map",
			type: (nil, nil) => { A, B in (A --> B) --> List.ref[A] --> List.ref[B] },
			value: (nil, nil, nil, nil) => { A, B, transform, list in list[List.ref[B], (nil, nil) => { cons[B, transform[$0], _map[A, B, transform, $1]] }, `nil`[B]] })

		let pure = Declaration("List.pure",
			type: nil => { A in A --> List.ref[A] },
			value: (nil, nil) => { A, a in cons[A, a, `nil`[A]] })

		let _cat: Term = "cat"
		let cat = Declaration("cat",
			type: nil => { A in List.ref[A] --> List.ref[A] --> List.ref[A] },
			value: (nil, nil, nil) => { A, x, y in x[List.ref[A], (nil, nil) => { cons[A, $0, _cat[A, $1, y]] }, y] })

		let _join: Term = "List.join"
		let join = Declaration("List.join",
			type: nil => { A in List.ref[List.ref[A]] --> List.ref[A] },
			value: (nil, nil) => { A, list in list[List.ref[A], (nil, nil) => { cat.ref[A, $0, _join[A, $1]] }, `nil`[A]] })

		let bind = Declaration("List.bind",
			type: (nil, nil) => { A, B in (A --> List.ref[B]) --> List.ref[A] --> List.ref[B] },
			value: (nil, nil, nil, nil) => { A, B, transform, list in join.ref[B, map.ref[A, List.ref[B], transform, list]] })

		return Module("List", [ List, map, pure, cat, join, bind ])
	}
}


import Prelude
