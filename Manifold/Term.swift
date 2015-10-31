//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Term: IntegerLiteralConvertible, StringLiteralConvertible, TermContainerType {
	case In(() -> Expression<Term>)


	public init(_ expression: () -> Expression<Term>) {
		self = .In(expression)
	}

	public init(_ expression: Expression<Term>) {
		self.init { expression }
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self.init(.Variable(.Global(value)))
	}


	// MARK: TermContainerType

	public var out: Expression<Term> {
		switch self {
		case let .In(f):
			return f()
		}
	}
}
