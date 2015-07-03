//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression<Recur>: BooleanLiteralConvertible, IntegerLiteralConvertible {
	// MARK: Analyses

	public func analysis<T>(
		@noescape ifUnit ifUnit: () -> T,
		@noescape ifUnitType: () -> T,
		@noescape ifType: Int -> T,
		@noescape ifVariable: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifLambda: (Int, Recur, Recur) -> T,
		@noescape ifProjection: (Recur, Bool) -> T,
		@noescape ifProduct: (Recur, Recur) -> T,
		@noescape ifBooleanType: () -> T,
		@noescape ifBoolean: Bool -> T,
		@noescape ifIf: (Recur, Recur, Recur) -> T,
		@noescape ifAnnotation: (Recur, Recur) -> T) -> T {
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
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifLambda: ((Int, Recur, Recur) -> T)? = nil,
		ifProjection: ((Recur, Bool) -> T)? = nil,
		ifProduct: ((Recur, Recur) -> T)? = nil,
		ifBooleanType: (() -> T)? = nil,
		ifBoolean: (Bool -> T)? = nil,
		ifIf: ((Recur, Recur, Recur) -> T)? = nil,
		ifAnnotation: ((Recur, Recur) -> T)? = nil,
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

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifUnit: const(.Unit),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifVariable: { .Variable($0) },
			ifApplication: { .Application(transform($0), transform($1)) },
			ifLambda: { .Lambda($0, transform($1), transform($2)) },
			ifProjection: { .Projection(transform($0), $1) },
			ifProduct: { .Product(transform($0), transform($1)) },
			ifBooleanType: const(.BooleanType),
			ifBoolean: { .Boolean($0) },
			ifIf: { .If(transform($0), transform($1), transform($2)) },
			ifAnnotation: { .Annotation(transform($0), transform($1)) })
	}


	// MARK: BooleanLiteralConvertible

	public init(booleanLiteral value: Bool) {
		self = .Boolean(value)
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self = .Variable(.Local(value))
	}


	// MARK: Cases

	case Unit
	case UnitType
	case Type(Int)
	case Variable(Name)
	case Application(Recur, Recur)
	case Lambda(Int, Recur, Recur) // (Πx:A)B where B can depend on x
	case Projection(Recur, Bool)
	case Product(Recur, Recur)
	case BooleanType
	case Boolean(Bool)
	case If(Recur, Recur, Recur)
	case Annotation(Recur, Recur)
}

extension Expression where Recur: FixpointType {
	var destructured: Expression<Expression<Recur>> {
		return map { $0.out }
	}


	// MARK: Destructuring accessors

	public var lambda: (Int, Recur, Recur)? {
		return analysis(ifLambda: Optional.Some, otherwise: const(nil))
	}

	public var product: (Recur, Recur)? {
		return analysis(ifProduct: Optional.Some, otherwise: const(nil))
	}

	public var boolean: Bool? {
		return analysis(ifBoolean: Optional.Some, otherwise: const(nil))
	}


	// MARK: Substitution

	private func substitute(i: Int, _ expression: Expression) -> Expression {
		return cata { t in
			Recur(t.analysis(
				ifVariable: {
					$0.analysis(
						ifGlobal: const(t),
						ifLocal: { $0 == i ? expression : t })
				},
				ifApplication: Expression.Application,
				ifLambda: Expression.Lambda,
				ifProjection: Expression.Projection,
				ifProduct: Expression.Product,
				ifIf: Expression.If,
				otherwise: const(t)))
			} (Recur(self)).out
	}
}


import Prelude
