//  Copyright © 2015 Rob Rix. All rights reserved.

public enum AnnotatedTerm<Annotation>: TermContainerType {
	indirect case Unroll(Annotation, Expression<AnnotatedTerm>)

	public var annotation: Annotation {
		return destructure.0
	}

	public var destructure: (Annotation, Expression<AnnotatedTerm>) {
		switch self {
		case let .Unroll(all):
			return all
		}
	}


	// MARK: TermContainerType

	public var out: Expression<AnnotatedTerm> {
		return destructure.1
	}
}

public func == <Annotation: Equatable> (left: AnnotatedTerm<Annotation>, right: AnnotatedTerm<Annotation>) -> Bool {
	return left.annotation == right.annotation && Expression.equal(==)(left.out, right.out)
}
