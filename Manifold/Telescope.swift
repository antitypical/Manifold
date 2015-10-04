//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Term, Term -> Telescope)
}
