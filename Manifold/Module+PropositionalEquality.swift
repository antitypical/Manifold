//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var propositionalEquality: Module {
		let Identical = Declaration("≡",
			type: nil => { A in A --> A --> .Type },
			value: nil => { A in (A, A) => { x, y in .Type => { Motive in (A --> A --> Motive) --> Motive } } })

		let refl = Declaration("refl",
			type: nil => { A in A => { a in Identical.ref[A, a, a] } },
			value: nil)

		return Module("PropositionalEquality", [ Identical, refl ])
	}
}
