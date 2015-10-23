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

	public func value(recur: Recur, transform: Recur -> Recur = id) -> Recur {
		switch self {
		case .End:
			return transform(.Unit)
		case .Recursive(.End):
			return .lambda(recur, transform)
		case let .Recursive(rest):
			return .lambda(recur, { v in rest.value(recur, transform: { .Product(v, $0) } >>> transform) })
		case let .Argument(t, continuation):
			return .lambda(t, { v in
				switch continuation(v) {
				case .End:
					return transform(v)
				case let a:
					return a.value(recur, transform: { .Product(v, $0) } >>> transform)
				}
			})
		}
	}
}


import Prelude
