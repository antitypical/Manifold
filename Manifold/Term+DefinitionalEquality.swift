//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static func equate(left: Term, _ right: Term, _ environment: [Name:Term]) -> Term? {
		return TermDiff(left, right, environment).unified
	}
}
