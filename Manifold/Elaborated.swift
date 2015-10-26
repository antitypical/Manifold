//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType>: CustomDebugStringConvertible, Equatable, TermContainerType {
	indirect case Unroll(Term, Expression<Elaborated>)

	/// Construct an elaborated term by coiteration.
	public static func coiterate(elaborate: Term throws -> Expression<Term>)(_ seed: Term) rethrows -> Elaborated {
		return try .Unroll(seed, elaborate(seed).map { try coiterate(elaborate)($0) })
	}

	public var type: Term {
		return destructure.0
	}

	public var term: Term {
		return Term(term: self)
	}

	public var destructure: (Term, Expression<Elaborated>) {
		switch self {
		case let .Unroll(all):
			return all
		}
	}


	public func cata<Result>(transform: (Term, Expression<Result>) -> Result) -> Result {
		return transform(type, out.map { $0.cata(transform) })
	}

	public var debugDescription: String {
		return cata { type, out in
			switch out {
			case let .Type(n):
				return ".Unroll(\(String(reflecting: type)), .Type(\(n)))"
			case let .Variable(name):
				return ".Unroll(\(String(reflecting: type)), .Variable(\(String(reflecting: name))))"
			case let .Application(a, b):
				return ".Unroll(\(String(reflecting: type)), .Application(\(a), \(b)))"
			case let .Lambda(i, a, b):
				return ".Unroll(\(String(reflecting: type)), .Lambda(\(i), \(a), \(b)))"
			}
		}
	}


	// MARK: TermContainerType

	public var out: Expression<Elaborated> {
		return destructure.1
	}
}

public func == <Term: TermType> (left: Elaborated<Term>, right: Elaborated<Term>) -> Bool {
	return left.type == right.type && left.out == right.out
}
