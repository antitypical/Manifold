//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchList: Module {
		let List: Recur = "List"
		let list = Declaration("List",
			type: .Type --> .Type,
			value: (.Type, .Type) => { A, B in (A --> List[A] --> B) --> (.UnitType --> B) --> B })

		let cons = Declaration("cons",
			type: .Type => { A in A --> List[A] --> List[A] },
			value: .Type => { (A: Recur) in (A, List[A], .Type) => { head, tail, B in (A --> List[A] --> B, .UnitType --> B) => { ifCons, _ in ifCons[head, tail] } } })

		let `nil` = Declaration("nil",
			type: .Type => { (A: Recur) in List[A] },
			value: (.Type, .Type) => { A, B in (A --> List[A] --> B, .UnitType --> B) => { _, ifNil in ifNil[Recur.Unit] } })

		return Module("ChurchList", [ list, cons, `nil` ])
	}
}
