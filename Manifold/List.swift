//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var List: Definition {
		return (symbol: "List",
			value: lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, .Application(.Variable("List"), A)), .UnitType) } },
			type: lambda(.Type, const(.Type)))
	}

	public static var `nil`: Definition {
		return (symbol: "nil",
			value: .Annotation(.Product(.Boolean(false), .Unit), .Variable("List")),
			type: .Variable("List"))
	}

	public static var list: Space {
		return defineSpace([
			List,
			`nil`,
		])
	}
}


import Prelude
