//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var boolean: Module<Recur> {
		return Module([
			.Datatype("Boolean", .Type(0), [
				"true": .End,
				"false": .End
			])
		])
	}
}


import Prelude
