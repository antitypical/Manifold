//  Copyright © 2015 Rob Rix. All rights reserved.

enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)
}
