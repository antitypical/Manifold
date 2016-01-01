//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	indirect case Recursive(Name, Telescope)
	indirect case Argument(Name, Term, Telescope)
	case End


	public func fold(recur: Term, terminal: Term, index: Int, combine: (Name, Term, Term) -> Term) -> Term {
		switch self {
		case .End:
			return terminal
		case let .Recursive(name, rest):
			return combine(name, recur, rest.fold(recur, terminal: terminal, index: index + 1, combine: combine))
		case let .Argument(name, type, rest):
			return combine(name, type, rest.fold(recur, terminal: terminal, index: index + 1, combine: combine))
		}
	}
}
