//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var list: Module<Recur> {
		return Module([
			Declaration.Datatype("List", .Argument(.Type, {
				.End([
					"nil": .End,
					"cons": .Argument($0, const(.Recursive(.End)))
				])
			}))
		])
	}
}


import Prelude
