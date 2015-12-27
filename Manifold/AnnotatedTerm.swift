//  Copyright © 2015 Rob Rix. All rights reserved.

public enum AnnotatedTerm<Annotation>: TermContainerType {
	indirect case Unroll(Annotation, Scoping<AnnotatedTerm>)

	public var annotation: Annotation {
		get {
			return destructure.0
		}
		set {
			self = .Unroll(newValue, out)
		}
	}

	public var destructure: (Annotation, Scoping<AnnotatedTerm>) {
		switch self {
		case let .Unroll(all):
			return all
		}
	}


	// MARK: TermContainerType

	public var out: Scoping<AnnotatedTerm> {
		return destructure.1
	}

	public var freeVariables: Set<Name> {
		switch out {
		case let .Identity(expression):
			return expression.foldMap { $0.freeVariables }
		case let .Variable(name):
			return [ name ]
		case let .Abstraction(name, scope):
			return scope.freeVariables.subtract([ name ])
		}
	}
}

public func == <Annotation: Equatable> (left: AnnotatedTerm<Annotation>, right: AnnotatedTerm<Annotation>) -> Bool {
	return left.annotation == right.annotation && Scoping.equal(==)(left.out, right.out)
}
