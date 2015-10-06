//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Term, Term -> Telescope)

	public func type(recur: Term) -> Term {
		switch self {
		case .End:
			return .UnitType
		case let .Recursive(rest):
			return .lambda(recur, const(rest.type(recur)))
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).type(recur) })
		}
	}

	public func value(recur: Term, transform: Term -> Term = id) -> Term {
		switch self {
		case .End:
			return transform(.Unit)
		case let .Recursive(rest):
			return .lambda(recur, { v in rest.value(recur, transform: { .Product(v, $0) } >>> transform) })
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).value(recur) })
		}
	}
}


import Prelude
