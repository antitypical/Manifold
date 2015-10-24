//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Expression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifType ifType: Int -> T,
		@noescape ifVariable: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifLambda: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case let .Type(n):
			return ifType(n)
		case let .Variable(x):
			return ifVariable(x)
		case let .Application(a, b):
			return ifApplication(a, b)
		case let .Lambda(i, a, b):
			return ifLambda(i, a, b)
		}
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifType: { .Type($0) },
			ifVariable: Expression<T>.Variable,
			ifApplication: { .Application(transform($0), transform($1)) },
			ifLambda: { .Lambda($0, transform($1), transform($2)) })
	}


	// MARK: Cases

	case Type(Int)
	case Variable(Name)
	case Application(Recur, Recur)
	case Lambda(Int, Recur, Recur) // (Πx:A)B where B can depend on x
}


public func == <Recur: Equatable> (left: Expression<Recur>, right: Expression<Recur>) -> Bool {
	switch (left, right) {
	case let (.Type(i), .Type(j)):
		return i == j
	case let (.Variable(m), .Variable(n)):
		return m == n
	case let (.Application(t1, t2), .Application(u1, u2)):
		return t1 == u1 && t2 == u2
	case let (.Lambda(i, t, a), .Lambda(j, u, b)):
		return i == j && t == u && a == b
	default:
		return false
	}
}


import Prelude
