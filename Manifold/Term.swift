//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Term: Equatable, IntegerLiteralConvertible, StringLiteralConvertible, TermContainerType {
	case In(() -> Expression<Term>)


	public init(_ expression: () -> Expression<Term>) {
		self = .In(expression)
	}

	public init(_ expression: Expression<Term>) {
		self.init { expression }
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self.init(.Variable(.Local(value)))
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


public func == (left: Term, right: Term) -> Bool {
	return left.out == right.out
}
