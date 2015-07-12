//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var list: Module<Recur> {
		// List : λ A : Type . Type
		// List = λ A : Type . λ tag : Boolean . if tag then (A, List A) else Unit
		let List = Binding("List",
			lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, .Application(.Variable("List"), A)), .UnitType) } },
			lambda(.Type, const(.Type)))

		// nil : List
		// nil = (false, ()) : List
		let `nil` = Binding("nil",
			.Annotation(Recur.Product(.Boolean(false), .Unit), .Variable("List")),
			.Variable("List"))

		// cons : λ A : Type . λ _ : A . λ _ : List A . List A
		// cons = λ A : Type . λ first : A . λ rest : List A . (true, (first, rest)) : List A
		let cons = Binding("cons",
			lambda(.Type) { A in Recur.lambda(A) { first in Recur.lambda(.Application(.Variable("List"), A)) { rest in .Annotation(.Product(.Boolean(true), .Product(first, rest)), .Variable("List")) } } },
			.Variable("List"))

		return Module([ List, `nil`, cons ])
	}
}


import Prelude
