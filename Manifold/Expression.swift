//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Expression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnit ifUnit: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifVariable: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifLambda: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case .Unit:
			return ifUnit()
		case .UnitType:
			return ifUnitType()
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

	public func analysis<T>(
		ifUnit ifUnit: (() -> T)? = nil,
		ifUnitType: (() -> T)? = nil,
		ifType: (Int -> T)? = nil,
		ifVariable: (Name -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifLambda: ((Int, Recur, Recur) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifUnit: { ifUnit?() ?? otherwise() },
			ifUnitType: { ifUnitType?() ?? otherwise() },
			ifType: { ifType?($0) ?? otherwise() },
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifLambda: { ifLambda?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifUnit: const(.Unit),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifVariable: Expression<T>.Variable,
			ifApplication: { .Application(transform($0), transform($1)) },
			ifLambda: { .Lambda($0, transform($1), transform($2)) })
	}


	// MARK: Cases

	case Unit
	case UnitType
	case Type(Int)
	case Variable(Name)
	case Application(Recur, Recur)
	case Lambda(Int, Recur, Recur) // (Πx:A)B where B can depend on x
}


public func == <Recur: Equatable> (left: Expression<Recur>, right: Expression<Recur>) -> Bool {
	switch (left, right) {
	case (.Unit, .Unit), (.UnitType, .UnitType):
		return true
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
