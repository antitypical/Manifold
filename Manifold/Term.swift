//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Term: CustomDebugStringConvertible, CustomStringConvertible, TermType {
	private var expression: () -> Expression<Term>


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
		self.expression = expression
	}

	public var out: Expression<Term> {
		return expression()
	}
}


import Either
import Prelude
