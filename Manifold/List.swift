//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var List: Definition {
		// List : λ A : Type . Type
		// List = λ A : Type . λ tag : Boolean . if tag then (A, List A) else Unit
		return (symbol: "List",
			value: lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, .Application(.Variable("List"), A)), .UnitType) } },
			type: lambda(.Type, const(.Type)))
	}

	public static var `nil`: Definition {
		// nil : List
		// nil = (false, ()) : List
		return (symbol: "nil",
			value: .Annotation(.Product(.Boolean(false), .Unit), .Variable("List")),
			type: .Variable("List"))
	}

	public static var cons: Definition {
		// cons : λ A : Type . λ _ : A . λ _ : List A . List A
		// cons = λ A : Type . λ first : A . λ rest : List A . (true, (first, rest)) : List A
		return (symbol: "cons",
			value: lambda(.Type) { A in Recur.lambda(A) { first in Recur.lambda(.Application(.Variable("List"), A)) { rest in .Annotation(.Product(.Boolean(true), .Product(first, rest)), .Variable("List")) } } },
			type: .Variable("List"))
	}

	public static var list: Space {
		return defineSpace([
			List,
			`nil`,
			cons,
		])
	}
}


import Prelude
