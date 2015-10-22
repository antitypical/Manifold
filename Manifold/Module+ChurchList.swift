//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var churchList: Module {
		let List: Recur = "List"
		let list = Declaration("List",
			type: .Type --> .Type,
			value: (.Type, .Type) => { A, B in (A --> List[A] --> B) --> (.UnitType --> B) --> B })

		return Module("ChurchList", [ list ])
	}
}
