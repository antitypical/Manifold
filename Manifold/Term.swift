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


// This would be an extension on `FixpointType` if protocol extensions could have inheritance clauses.
extension Term: BooleanLiteralConvertible, StringLiteralConvertible {
	public init(booleanLiteral: Bool) {
		self = .Boolean(booleanLiteral)
	}

	public init(stringLiteral: String) {
		self = .Variable(.Global(stringLiteral))
	}
}


import Either
import Prelude
