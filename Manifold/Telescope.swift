//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	indirect case Recursive(Telescope)
	indirect case Argument(Name?, Term, Telescope)
	case End


	public func fold(recur: Term, terminal: Term, combine: (Term, Term) -> Term) -> Term {
		switch self {
		case .End:
			return terminal
		case let .Recursive(rest):
			return combine(recur, rest.fold(recur, terminal: terminal, combine: combine))
		case let .Argument(.Some(name), type, rest):
			return (name, type) => rest.fold(recur, terminal: terminal, combine: combine)
		case let .Argument(.None, type, rest):
			return type --> rest.fold(recur, terminal: terminal, combine: combine)
		}
	}
}
