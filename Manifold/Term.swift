//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: CustomStringConvertible, FixpointType, Hashable {
	private var expression: () -> Expression<Term>


	// MARK: CustomStringConvertible

	public var description: String {
		return out.description
	}


	// MARK: FixpointType

	public init(_ expression: () -> Expression<Term>) {
		self.expression = expression
	}

	public var out: Expression<Term> {
		return expression()
	}


	// MARK: Hashable

	public var hashValue: Int {
		return out.hashValue
	}
}


import Either
import Prelude
