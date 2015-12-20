//  Copyright © 2015 Rob Rix. All rights reserved.

enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)

	init(_ term: Term) {
		self = .Roll(term.out.map(TermDiff.init))
	}
}
