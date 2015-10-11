//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Term: CustomDebugStringConvertible, CustomStringConvertible, TermType {
	case In(() -> Expression<Term>)


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return out.debugDescription
	}


	// MARK: CustomStringConvertible

	public var description: String {
		switch out {
		case let .Lambda(i, type, body):
			if body.out.freeVariables.contains(i) { fallthrough }

			return "\(type) → \(body)"
		default:
			return out.description
		}
	}


	// MARK: TermType

	public init(_ expression: () -> Expression<Term>) {
		self = .In(expression)
	}

	public var out: Expression<Term> {
		switch self {
		case let .In(f):
			return f()
		}
	}
}


import Either
import Prelude
