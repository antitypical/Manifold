//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var list: Module<Recur> {
		let List = Recur("List")

		// List : λ A : Type . Type
		// List = λ A : Type . λ tag : Boolean . if tag then (A, List A) else Unit
		let list = Binding("List",
			lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, .Application(List, A)), .UnitType) } },
			lambda(.Type, const(.Type)))

		// nil : List
		// nil = (false, ()) : List
		let `nil` = Binding("[]",
			.Annotation(Recur.Product(.Boolean(false), .Unit), List),
			List.out)

		// cons : λ A : Type . λ _ : A . λ _ : List A . List A
		// cons = λ A : Type . λ first : A . λ rest : List A . (true, (first, rest)) : List A
		let cons = Binding("::",
			lambda(.Type) { A in Recur.lambda(A) { first in Recur.lambda(.Application(List, A)) { rest in .Annotation(.Product(.Boolean(true), .Product(first, rest)), List) } } },
			List.out)

		return Module([ list, `nil`, cons ])
	}
}


import Prelude
