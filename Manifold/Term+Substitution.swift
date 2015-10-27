//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public func substitute(i: Int, _ expression: Term) -> Term {
		return cata { (t: Expression<Term>) in
			switch t {
			case let .Variable(.Local(j)) where i == j:
				return expression
			default:
				return Term(t)
			}
		}
	}
}


import Prelude
