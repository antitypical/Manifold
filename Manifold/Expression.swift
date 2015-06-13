//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Checkable<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnitTerm ifUnitTerm: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifBound: Int -> T,
		@noescape ifFree: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifPi: (Recur, Recur) -> T,
		@noescape ifProjection: (Recur, Bool) -> T,
		@noescape ifSigma: (Recur, Recur) -> T,
		@noescape ifBooleanType: () -> T,
		@noescape ifBooleanTerm: Bool -> T,
		@noescape ifIf: (Recur, Recur, Recur) -> T) -> T {
		switch self {
		case .UnitTerm:
			return ifUnitTerm()
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
		case let .Pi(a, b):
			return ifPi(a, b)
		case let .Projection(a, b):
			return ifProjection(a, b)
		case let .Sigma(a, b):
			return ifSigma(a, b)
		case .BooleanType:
			return ifBooleanType()
		case let .BooleanTerm(b):
			return ifBooleanTerm(b)
		case let .If(a, b, c):
			return ifIf(a, b, c)
		}
	}

	public func analysis<T>(
		ifUnitTerm ifUnitTerm: (() -> T)? = nil,
		ifUnitType: (() -> T)? = nil,
		ifType: (Int -> T)? = nil,
		ifBound: (Int -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifPi: ((Recur, Recur) -> T)? = nil,
		ifProjection: ((Recur, Bool) -> T)? = nil,
		ifSigma: ((Recur, Recur) -> T)? = nil,
		ifBooleanType: (() -> T)? = nil,
		ifBooleanTerm: (Bool -> T)? = nil,
		ifIf: ((Recur, Recur, Recur) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifUnitTerm: { ifUnitTerm?() ?? otherwise() },
			ifUnitType: { ifUnitType?() ?? otherwise() },
			ifType: { ifType?($0) ?? otherwise() },
			ifBound: { ifBound?($0) ?? otherwise() },
			ifFree: { ifFree?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifProjection: { ifProjection?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() },
			ifBooleanType: { ifBooleanType?() ?? otherwise() },
			ifBooleanTerm: { ifBooleanTerm?($0) ?? otherwise() },
			ifIf: { ifIf?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Checkable<T> {
		return analysis(
			ifUnitTerm: const(.UnitTerm),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifBound: { .Bound($0) },
			ifFree: { .Free($0) },
			ifApplication: { .Application(transform($0), transform($1)) },
			ifPi: { .Pi(transform($0), transform($1)) },
			ifProjection: { .Projection(transform($0), $1) },
			ifSigma: { .Sigma(transform($0), transform($1)) },
			ifBooleanType: const(.BooleanType),
			ifBooleanTerm: { .BooleanTerm($0) },
			ifIf: { .If(transform($0), transform($1), transform($2)) })
	}


	// MARK: Cases

	case UnitTerm
	case UnitType
	case Type(Int)
	case Bound(Int)
	case Free(Name)
	case Application(Recur, Recur)
	case Pi(Recur, Recur) // (Πx:A)B where B can depend on x
	case Projection(Recur, Bool)
	case Sigma(Recur, Recur) // (Σx:A)B where B can depend on x
	case BooleanType
	case BooleanTerm(Bool)
	case If(Recur, Recur, Recur)
}


import Prelude
