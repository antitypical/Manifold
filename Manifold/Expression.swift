//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Inferable<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnit ifUnit: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifVariable: Name -> T,
		@noescape ifApplication: (Recur, Checkable<Recur>) -> T,
		@noescape ifLambda: (Int, Checkable<Recur>, Checkable<Recur>) -> T,
		@noescape ifProjection: (Recur, Bool) -> T,
		@noescape ifProduct: (Checkable<Recur>, Checkable<Recur>) -> T,
		@noescape ifBooleanType: () -> T,
		@noescape ifBoolean: Bool -> T,
		@noescape ifIf: (Recur, Recur, Recur) -> T,
		@noescape ifAnnotation: (Checkable<Recur>, Checkable<Recur>) -> T) -> T {
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
		case let .Projection(a, b):
			return ifProjection(a, b)
		case let .Product(a, b):
			return ifProduct(a, b)
		case .BooleanType:
			return ifBooleanType()
		case let .Boolean(b):
			return ifBoolean(b)
		case let .If(a, b, c):
			return ifIf(a, b, c)
		case let .Annotation(term, type):
			return ifAnnotation(term, type)
		}
	}

	public func analysis<T>(
		ifUnit ifUnit: (() -> T)? = nil,
		ifUnitType: (() -> T)? = nil,
		ifType: (Int -> T)? = nil,
		ifVariable: (Name -> T)? = nil,
		ifApplication: ((Recur, Checkable<Recur>) -> T)? = nil,
		ifLambda: ((Int, Checkable<Recur>, Checkable<Recur>) -> T)? = nil,
		ifProjection: ((Recur, Bool) -> T)? = nil,
		ifProduct: ((Checkable<Recur>, Checkable<Recur>) -> T)? = nil,
		ifBooleanType: (() -> T)? = nil,
		ifBoolean: (Bool -> T)? = nil,
		ifIf: ((Recur, Recur, Recur) -> T)? = nil,
		ifAnnotation: ((Checkable<Recur>, Checkable<Recur>) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifUnit: { ifUnit?() ?? otherwise() },
			ifUnitType: { ifUnitType?() ?? otherwise() },
			ifType: { ifType?($0) ?? otherwise() },
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifLambda: { ifLambda?($0) ?? otherwise() },
			ifProjection: { ifProjection?($0) ?? otherwise() },
			ifProduct: { ifProduct?($0) ?? otherwise() },
			ifBooleanType: { ifBooleanType?() ?? otherwise() },
			ifBoolean: { ifBoolean?($0) ?? otherwise() },
			ifIf: { ifIf?($0) ?? otherwise() },
			ifAnnotation: { ifAnnotation?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Inferable<T> {
		return analysis(
			ifUnit: const(.Unit),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifVariable: { .Variable($0) },
			ifApplication: { .Application(transform($0), $1.map(transform)) },
			ifLambda: { .Lambda($0, $1.map(transform), $2.map(transform)) },
			ifProjection: { .Projection(transform($0), $1) },
			ifProduct: { .Product($0.map(transform), $1.map(transform)) },
			ifBooleanType: const(.BooleanType),
			ifBoolean: { .Boolean($0) },
			ifIf: { .If(transform($0), transform($1), transform($2)) },
			ifAnnotation: { .Annotation($0.map(transform), $1.map(transform)) })
	}


	// MARK: Cases

	case Unit
	case UnitType
	case Type(Int)
	case Variable(Name)
	case Application(Recur, Checkable<Recur>)
	case Lambda(Int, Checkable<Recur>, Checkable<Recur>) // (Πx:A)B where B can depend on x
	case Projection(Recur, Bool)
	case Product(Checkable<Recur>, Checkable<Recur>)
	case BooleanType
	case Boolean(Bool)
	case If(Recur, Recur, Recur)
	case Annotation(Checkable<Recur>, Checkable<Recur>)
}


public enum Checkable<Recur> {
	public func analysis<T>(@noescape ifInferable ifInferable: Recur -> T) -> T {
		switch self {
		case let .Inferable(v):
			return ifInferable(v)
		}
	}

	public func map<T>(@noescape transform: Recur -> T) -> Checkable<T> {
		return analysis(ifInferable: { .Inferable(transform($0)) })
	}

	case Inferable(Recur)

}


import Prelude
