//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Term, Term -> Telescope)

	public func type(recur: Term, transform: Term -> Term = id) -> Term {
		switch self {
		case .End:
			return transform(.UnitType)
		case let .Recursive(rest):
			return .lambda(recur, const(rest.type(recur, transform: { .Product(recur, $0) } >>> transform)))
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).type(recur, transform: { .Product(t, $0) } >>> transform) })
		}
	}

	public func value(recur: Term, transform: Term -> Term = id) -> Term {
		switch self {
		case .End:
			return transform(.Unit)
		case let .Recursive(rest):
			return .lambda(recur, { v in rest.value(recur, transform: { .Product(v, $0) } >>> transform) })
		case let .Argument(t, continuation):
			return .lambda(t, { v in continuation(v).value(recur, transform: { .Product(v, $0) } >>> transform) })
		}
	}
}


import Prelude
