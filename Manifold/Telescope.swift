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
			return .lambda(recur, { _ in rest.type(recur) })
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).type(recur) })
		}
	}

	public func value(recur: Term) -> Term {
		switch self {
		case .End:
			return .Unit
		case let .Recursive(rest):
			return .Product(recur, rest.value(recur))
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).value(recur) })
		}
	}
}
