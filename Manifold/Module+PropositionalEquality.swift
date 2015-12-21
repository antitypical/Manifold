//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var propositionalEquality: Module {
		let Identical = Declaration("≡",
			type: nil => { A in A --> A --> .Type },
			value: nil => { A in (A, A) => { x, y in .Type => { Motive in (A --> A --> Motive) --> Motive } } })

		return Module("PropositionalEquality", [ Identical ])
	}
}
