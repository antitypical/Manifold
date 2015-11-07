//  Copyright © 2015 Rob Rix. All rights reserved.

public enum AnnotatedTerm: Equatable, TermContainerType {
	public typealias Annotation = Term
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

public func == (left: AnnotatedTerm, right: AnnotatedTerm) -> Bool {
	return left.annotation == right.annotation && left.out == right.out
}
