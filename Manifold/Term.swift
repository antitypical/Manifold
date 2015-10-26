//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Term: TermType {
	case In(() -> Expression<Term>)


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
