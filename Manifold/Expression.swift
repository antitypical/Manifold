//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnit ifUnit: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifBound: Int -> T,
		@noescape ifFree: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifLambda: (Int, Recur, Recur) -> T,
		@noescape ifProjection: (Recur, Bool) -> T,
		@noescape ifSigma: (Int, Recur, Recur) -> T,
		@noescape ifBooleanType: () -> T,
		@noescape ifBoolean: Bool -> T,
		@noescape ifIf: (Recur, Recur, Recur) -> T) -> T {
		switch self {
		case .Unit:
			return ifUnit()
		case .UnitType:
			return ifUnitType()
		case let .Type(n):
			return ifType(n)
		case let .Bound(x):
			return ifBound(x)
		case let .Free(x):
			return ifFree(x)
		case let .Application(a, b):
			return ifApplication(a, b)
		case let .Lambda(i, a, b):
			return ifLambda(i, a, b)
		case let .Projection(a, b):
			return ifProjection(a, b)
		case let .Sigma(i, a, b):
			return ifSigma(i, a, b)
		case .BooleanType:
			return ifBooleanType()
		case let .Boolean(b):
			return ifBoolean(b)
		case let .If(a, b, c):
			return ifIf(a, b, c)
		}
	}

	public func analysis<T>(
		ifUnit ifUnit: (() -> T)? = nil,
		ifUnitType: (() -> T)? = nil,
		ifType: (Int -> T)? = nil,
		ifBound: (Int -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifLambda: ((Int, Recur, Recur) -> T)? = nil,
		ifProjection: ((Recur, Bool) -> T)? = nil,
		ifSigma: ((Int, Recur, Recur) -> T)? = nil,
		ifBooleanType: (() -> T)? = nil,
		ifBoolean: (Bool -> T)? = nil,
		ifIf: ((Recur, Recur, Recur) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifUnit: { ifUnit?() ?? otherwise() },
			ifUnitType: { ifUnitType?() ?? otherwise() },
			ifType: { ifType?($0) ?? otherwise() },
			ifBound: { ifBound?($0) ?? otherwise() },
			ifFree: { ifFree?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifLambda: { ifLambda?($0) ?? otherwise() },
			ifProjection: { ifProjection?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() },
			ifBooleanType: { ifBooleanType?() ?? otherwise() },
			ifBoolean: { ifBoolean?($0) ?? otherwise() },
			ifIf: { ifIf?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifUnit: const(.Unit),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifBound: { .Bound($0) },
			ifFree: { .Free($0) },
			ifApplication: { .Application(transform($0), transform($1)) },
			ifLambda: { .Lambda($0, transform($1), transform($2)) },
			ifProjection: { .Projection(transform($0), $1) },
			ifSigma: { .Sigma($0, transform($1), transform($2)) },
			ifBooleanType: const(.BooleanType),
			ifBoolean: { .Boolean($0) },
			ifIf: { .If(transform($0), transform($1), transform($2)) })
	}


	// MARK: Cases

	case Unit
	case UnitType
	case Type(Int)
	case Bound(Int)
	case Free(Name)
	case Application(Recur, Recur)
	case Lambda(Int, Recur, Recur) // (Πx:A)B where B can depend on x
	case Projection(Recur, Bool)
	case Sigma(Int, Recur, Recur) // (Σx:A)B where B can depend on x
	case BooleanType
	case Boolean(Bool)
	case If(Recur, Recur, Recur)
}


import Prelude
