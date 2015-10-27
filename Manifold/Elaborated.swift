//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType>: Equatable, TermContainerType {
	indirect case Unroll(Term, Expression<Elaborated>)

	public var type: Term {
		return destructure.0
	}

	public var destructure: (Term, Expression<Elaborated>) {
		switch self {
		case let .Unroll(all):
			return all
		}
	}


	// MARK: TermContainerType

	public var out: Expression<Elaborated> {
		return destructure.1
	}
}

public func == (left: Elaborated<Term>, right: Elaborated<Term>) -> Bool {
	return left.type == right.type && left.out == right.out
}
