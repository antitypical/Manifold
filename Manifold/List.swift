//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var List: Binding<Recur> {
		// List : λ A : Type . Type
		// List = λ A : Type . λ tag : Boolean . if tag then (A, List A) else Unit
		return Binding("List",
			lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, .Application(.Variable("List"), A)), .UnitType) } },
			lambda(.Type, const(.Type)))
	}

	public static var `nil`: Binding<Recur> {
		// nil : List
		// nil = (false, ()) : List
		return Binding("nil",
			.Annotation(.Product(.Boolean(false), .Unit), .Variable("List")),
			.Variable("List"))
	}

	public static var cons: Binding<Recur> {
		// cons : λ A : Type . λ _ : A . λ _ : List A . List A
		// cons = λ A : Type . λ first : A . λ rest : List A . (true, (first, rest)) : List A
		return Binding("cons",
			lambda(.Type) { A in Recur.lambda(A) { first in Recur.lambda(.Application(.Variable("List"), A)) { rest in .Annotation(.Product(.Boolean(true), .Product(first, rest)), .Variable("List")) } } },
			.Variable("List"))
	}

	public static var list: Module<Recur> {
		return Module([ List, `nil`, cons ])
	}
}


import Prelude
