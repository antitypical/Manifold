//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope<Recur: TermType> {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Recur, Recur -> Telescope)


	public func fold(recur: Recur, terminal: Recur, combine: (Recur, Recur) -> Recur) -> Recur {
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
