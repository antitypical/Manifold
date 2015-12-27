//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	indirect case Recursive(Telescope)
	indirect case Argument(Term, Telescope)
	case End


	public func fold(recur: Term, terminal: Term, index: Int = 0, combine: (Term, Term) -> Term) -> Term {
		switch self {
		case .End:
			return terminal
		case let .Recursive(rest):
			return combine(recur, rest.fold(recur, terminal: terminal, index: index + 1, combine: combine))
		case let .Argument(type, rest):
			return (Name.Local(index), type) => rest.fold(recur, terminal: terminal, index: index + 1, combine: combine)
		}
	}
}
