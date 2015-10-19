//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType>: TermContainerType {
	indirect case Unroll(Term, Expression<Elaborated>)

	/// Construct an elaborated term by coiteration.
	public static func coiterate(elaborate: Term -> Expression<Term>)(_ seed: Term) -> Elaborated {
		return .Unroll(seed, elaborate(seed).map(coiterate(elaborate)))
	}

	public var type: Term {
		switch self {
		case let .Unroll(type, _):
			return type
		}
	}

	public var term: Term {
		return Term(term: self)
	}


	// MARK: TermContainerType

	public var out: Expression<Elaborated> {
		switch self {
		case let .Unroll(_, term):
			return term
		}
	}
}