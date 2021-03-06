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


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return ".Unroll(\(String(reflecting: annotation)), \(cata { $0.debugDescription }))"
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return "\(annotation) @ \(cata { $0.description })"
	}


	// MARK: Equatable

	public static func equal(annotationEqual: (Annotation, Annotation) -> Bool)(_ left: AnnotatedTerm, _ right: AnnotatedTerm) -> Bool {
		return annotationEqual(left.annotation, right.annotation) && Scoping.equal(equal(annotationEqual))(left.out, right.out)
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
	return AnnotatedTerm.equal(==)(left, right)
}
