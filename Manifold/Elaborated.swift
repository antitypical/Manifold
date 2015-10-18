//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType> {
	indirect case Unroll(Term, Expression<Elaborated>)

	public var type: Term {
		switch self {
		case let .Unroll(type, _):
			return type
		}
	}
}
