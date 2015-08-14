//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Term: CustomDebugStringConvertible, CustomStringConvertible, TermType {
	public init<T: TermType>(_ term: T) {
		self.init(term.out.map(Term.init))
	}

	private var expression: () -> Expression<Term>


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return out.debugDescription
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return out.description
	}


	// MARK: TermType

	public init(_ expression: () -> Expression<Term>) {
		self.expression = expression
	}

	public var out: Expression<Term> {
		return expression()
	}
}


// This would be an extension on `TermType` if protocol extensions could have inheritance clauses.
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
