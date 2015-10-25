//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType>: TermContainerType {
	indirect case Unroll(Term, Expression<Elaborated>)

	/// Construct an elaborated term by coiteration.
	public static func coiterate(elaborate: Term throws -> Expression<Term>)(_ seed: Term) rethrows -> Elaborated {
		return try .Unroll(seed, elaborate(seed).map { try coiterate(elaborate)($0) })
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
