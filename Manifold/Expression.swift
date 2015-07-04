//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression<Recur>: BooleanLiteralConvertible, CustomStringConvertible, IntegerLiteralConvertible {
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


	// MARK: CustomStringConvertible

	public var description: String {
		let renderNumerals: (Int, String) -> String = { n, alphabet in
			"".join(lazy(n.digits(alphabet.characters.count)).map { String(atModular(alphabet.characters, offset: $0)) })
		}
		let alphabet = "abcdefghijklmnopqrstuvwxyz"
		switch self {
		case .Unit:
			return "()"
		case .UnitType:
			return "Unit"

		case let .Type(n) where n == 0:
			return "Type"
		case let .Type(n):
			let subscripts = "₀₁₂₃₄₅₆₇₈₉"
			return "Type" + renderNumerals(n, subscripts)

		case let .Variable(name):
			return name.analysis(
				ifGlobal: id,
				ifLocal: { renderNumerals($0, alphabet) })

		case let .Application(a, b):
			return "(\(a) \(b))"

		case let .Lambda(variable, type, body):
			return "λ \(renderNumerals(variable, alphabet)) : \(type) . \(body)"

		case let .Projection(term, branch):
			return "\(term).\(branch ? 1 : 0)"

		case let .Product(a, b):
			return "(\(a) × \(b))"

		case .BooleanType:
			return "Boolean"
		case let .Boolean(b):
			return String(b)

		case let .If(condition, then, `else`):
			return "if \(condition) then \(then) else \(`else`)"

		case let .Annotation(term, type):
			return "\(term) : \(type)"
		}
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
	// MARK: Higher-order construction

	public static func lambda(type: Expression, _ f: Recur -> Expression) -> Expression {
		var n = 0
		let body = f(Recur { .Variable(.Local(n)) })
		n = body.maxBoundVariable + 1
		return .Lambda(n, Recur(type), Recur(body))
	}


	// MARK: Destructuring accessors

	var destructured: Expression<Expression<Recur>> {
		return map { $0.out }
	}

	public var isType: Bool {
		return analysis(ifType: const(true), otherwise: const(false))
	}

	public var lambda: (Int, Recur, Recur)? {
		return analysis(ifLambda: Optional.Some, otherwise: const(nil))
	}

	public var product: (Recur, Recur)? {
		return analysis(ifProduct: Optional.Some, otherwise: const(nil))
	}

	public var boolean: Bool? {
		return analysis(ifBoolean: Optional.Some, otherwise: const(nil))
	}


	// MARK: Evaluation

	public func evaluate(environment: [Name: Expression] = [:]) -> Expression {
		switch destructured {
		case let .Variable(i):
			return environment[i] ?? self
		case let .Application(a, b):
			return a.evaluate(environment).lambda.map { i, _, body in body.out.substitute(i, b.evaluate(environment)) }!
		case let .Projection(a, b):
			return a.evaluate(environment).product.map { b ? $1 : $0 }.map { $0.out }!
		case let .If(condition, then, `else`):
			return condition.evaluate(environment).boolean!
				? then.evaluate(environment)
				: `else`.evaluate(environment)
		case let .Annotation(term, _):
			return term.evaluate(environment)
		default:
			return self
		}
	}


	// MARK: Substitution

	func substitute(i: Int, _ expression: Expression) -> Expression {
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


	// MARK: Bound variables

	private var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: {
					max($0, $1)
				},
				ifLambda: { max($0.0, $0.1) },
				ifProjection: { $0.0 },
				ifProduct: { max($0, $1) },
				ifIf: { max($0, $1, $2) },
				ifAnnotation: { max($0, $1) },
				otherwise: const(-1))
		} (Recur(self))
	}


	// MARK: Hashable

	var hashValue: Int {
		return cata {
			return $0.map { $0.hashValue }
				.analysis(
					ifUnit: { 1 },
					ifUnitType: { 2 },
					ifType: { 3 ^ $0 },
					ifVariable: { 5 ^ $0.hashValue },
					ifApplication: { 7 ^ $0 ^ $1 },
					ifLambda: { 11 ^ $0 ^ $1 ^ $2 },
					ifProjection: { 13 ^ $0 ^ $1.hashValue },
					ifProduct: { 17 ^ $0 ^ $1 },
					ifBooleanType: { 19 },
					ifBoolean: { 23 ^ $0.hashValue },
					ifIf: { 29 ^ $0 ^ $1 ^ $2 },
					ifAnnotation: { 31 ^ $0 ^ $1 })
		} (Recur(self))
	}
}

extension Expression where Recur: FixpointType, Recur: Equatable {
	// MARK: Typechecking

	public func typecheck(environment: [Name: Expression] = [:]) -> Either<Error, Expression> {
		switch destructured {
		case .Unit:
			return .right(.UnitType)
		case .Boolean:
			return .right(.BooleanType)

		case let .If(condition, then, `else`):
			return condition.typecheck(environment, against: .BooleanType)
				.flatMap { _ in
					(then.typecheck(environment) &&& `else`.typecheck(environment))
						.map { a, b in
							a == b
								? a
								: Expression.lambda(.BooleanType) { Expression.If($0, Recur(a), Recur(b)) }
						}
				}

		case .UnitType, .BooleanType:
			return .right(.Type(0))
		case let .Type(n):
			return .right(.Type(n + 1))

		case let .Variable(i):
			return environment[i].map(Either.Right) ?? Either.Left("Unexpectedly free variable \(i)")

		case let .Lambda(i, type, body):
			return type.typecheck(environment, against: .Type(0))
				.flatMap { _ in
					body.typecheck(environment + [ .Local(i): type ])
						.map { Expression.lambda(type, const($0)) }
			}

		case let .Product(a, b):
			return (a.typecheck(environment) &&& b.typecheck(environment))
				.map { A, B in Expression.lambda(A, const(B)) }

		case let .Application(a, b):
			return a.typecheck(environment)
				.flatMap { A in
					A.analysis(
						ifLambda: { i, type, body in
							b.typecheck(environment, against: type.out).map { body.out.substitute(i, $0) }
						},
						otherwise: const(Either.Left("illegal application of \(a) : \(A) to \(b)")))
				}

		case let .Projection(term, branch):
			return term.typecheck(environment)
				.flatMap { type in
					type.analysis(
						ifLambda: { i, A, B in
							Either.Right(branch ? B.out.substitute(i, A.out) : A.out)
						},
						otherwise: const(Either.Left("illegal attempt to project field \(branch ? 1 : 0) of value \(term) of non-product type \(type)")))
				}

		case let .Annotation(term, type):
			return type.typecheck(environment, against: .Type(0))
				.map { $0.evaluate() }
				.flatMap { type in term.typecheck(environment, against: type) }
		}
	}

	public func typecheck(environment: [Name: Expression], against: Expression) -> Either<Error, Expression> {
		return typecheck(environment)
			.flatMap { type in
				type == against || against == .Type(0) && type.isType
					? Either.Right(type)
					: Either.Left("Type mismatch: expected \(String(reflecting: self)) to be of type \(String(reflecting: against)), but it was actually of type \(String(reflecting: type)) in environment \(environment)")
		}
	}
}


private func atModular<C: CollectionType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	return collection[advance(collection.startIndex, offset % distance(collection.startIndex, collection.endIndex), collection.endIndex)]
}


import Either
import Prelude
