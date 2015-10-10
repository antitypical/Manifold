//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Telescope<Recur: TermType> {
	case End
	indirect case Recursive(Telescope)
	indirect case Argument(Recur, Recur -> Telescope)

	public func type(recur: Recur, transform: Recur -> Recur = id) -> Recur {
		switch self {
		case .End:
			return transform(recur)
		case let .Recursive(rest):
			return .lambda(recur, const(rest.type(recur, transform: { .Product(recur, $0) } >>> transform)))
		case let .Argument(t, continuation):
			return .lambda(t, { continuation($0).type(recur, transform: { .Product(t, $0) } >>> transform) })
		}
	}

	public func constructedType(recur: Recur) -> Recur {
		switch self {
		case .End:
			return .UnitType
		case let .Recursive(rest):
			return .Product(recur, rest.constructedType(recur))
		case let .Argument(t, continuation):
			return .Product(t, continuation(.Unit).constructedType(recur))
		}
	}

	public func value(recur: Recur, transform: Recur -> Recur = id) -> Recur {
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
