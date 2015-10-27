//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	indirect case Recursive(Telescope)
	indirect case Argument(Term, Term -> Telescope)
	case End


	public func fold(recur: Term, terminal: Term, combine: (Term, Term) -> Term) -> Term {
		switch self {
		case .End:
			return terminal
		case let .Recursive(rest):
			return combine(recur, rest.fold(recur, terminal: terminal, combine: combine))
		case let .Argument(type, continuation):
			return type => { continuation($0).fold(recur, terminal: terminal, combine: combine) }
		}
	}
}


import Prelude
