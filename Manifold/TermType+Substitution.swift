//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func substitute(i: Int, _ expression: Self) -> Self {
		return cata { (t: Expression<Self>) in
			switch t {
			case let .Variable(.Local(j)) where i == j:
				return expression
			default:
				return Self(t)
			}
		}
	}
}


import Prelude
