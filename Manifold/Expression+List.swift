//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var list: Module<Recur> {
		return Module([
			Declaration.Data("List", .Type, {
				[
					"nil": .End,
					"cons": .Argument($0, const(.Recursive(.End)))
				]
			})
		])
	}
}


import Prelude
