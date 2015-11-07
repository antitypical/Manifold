//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated: Equatable, TermContainerType {
	public typealias Annotation = Term
	indirect case Unroll(Annotation, Expression<Elaborated>)

	public var type: Term {
		return destructure.0
	}

	public var destructure: (Annotation, Expression<Elaborated>) {
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

public func == (left: Elaborated, right: Elaborated) -> Bool {
	return left.type == right.type && left.out == right.out
}
