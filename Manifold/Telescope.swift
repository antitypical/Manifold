//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope<Recur: TermType> {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Recur, Recur -> Telescope)

	public func type(recur: Recur) -> Recur {
		switch self {
		case .End:
			return recur
		case let .Recursive(rest):
			return .lambda(recur, const(rest.type(recur)))
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).type(recur) })
		}
	}

	public func constructedType(recur: Recur) -> Recur {
		switch self {
		case .End:
			return .UnitType
		case .Recursive(.End):
			return recur
		case let .Recursive(rest):
			return .Product(recur, rest.constructedType(recur))
		case let .Argument(t, continuation):
			switch continuation(0) {
			case .End:
				return t
			case let a:
				return .Product(t, a.constructedType(recur))
			}
		}
	}

	public func value(recur: Recur, transform: Recur -> Recur = id) -> Recur {
		switch self {
		case .End:
			return transform(.Unit)
		case .Recursive(.End):
			return .lambda(recur, transform)
		case let .Recursive(rest):
			return .lambda(recur, { v in rest.value(recur, transform: { .Product(v, $0) } >>> transform) })
		case let .Argument(t, continuation):
			return .lambda(t, { v in continuation(v).value(recur, transform: { .Product(v, $0) } >>> transform) })
		}
	}
}


import Prelude
