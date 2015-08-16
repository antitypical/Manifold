//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Expression<Recur>: BooleanLiteralConvertible, CustomDebugStringConvertible, CustomStringConvertible, IntegerLiteralConvertible, StringLiteralConvertible {
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


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		switch self {
		case .Unit:
			return ".Unit"
		case .UnitType:
			return ".UnitType"
		case let .Type(n):
			return ".Type(\(n))"
		case let .Variable(n):
			return ".Variable(\(String(reflecting: n)))"
		case let .Application(a, b):
			return ".Application(\(String(reflecting: a)), \(String(reflecting: b)))"
		case let .Lambda(i, a, b):
			return ".Lambda(\(i), \(String(reflecting: a)), \(String(reflecting: b)))"
		case let .Projection(a, field):
			return ".Projection(\(String(reflecting: a)), \(field))"
		case let .Product(a, b):
			return ".Product(\(String(reflecting: a)), \(String(reflecting: b)))"
		case .BooleanType:
			return ".BooleanType"
		case let .Boolean(a):
			return ".Boolean(\(a))"
		case let .If(a, b, c):
			return ".If(\(String(reflecting: a)), \(String(reflecting: b)), \(String(reflecting: c)))"
		case let .Annotation(a, b):
			return ".Annotation(\(String(reflecting: a)), \(String(reflecting: b)))"
		}
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
			return variable < 0
				? "λ _ : \(type) . \(body)"
				: "λ \(renderNumerals(variable, alphabet)) : \(type) . \(body)"

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


	// MARK: StringLiteralConvertible

	public init(stringLiteral: String) {
		self = .Variable(.Global(stringLiteral))
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

extension Expression where Recur: TermType {
	// MARK: First-order construction

	/// Constructs a sum type of the elements in `terms`.
	public static func Sum(terms: [Recur]) -> Expression {
		return terms.uncons.map { first, rest in
			rest.isEmpty
				? first.out
				: Expression.lambda(Recur(.BooleanType)) {
					Recur(.If($0, first, Recur(.Sum(Array(rest)))))
				}
		} ?? .UnitType
	}

	/// Constructs a (non-dependent) function type from `A` to `B`.
	public static func FunctionType(a: Recur, _ b: Recur) -> Expression {
		return .Lambda(-1, a, b)
	}

	/// Constructs a (non-dependent) function type from `A` to `B` to `C`.
	public static func FunctionType(a: Recur, _ b: Recur, _ c: Recur) -> Expression {
		return .FunctionType(a, Recur(FunctionType(b, c)))
	}


	// MARK: Higher-order construction

	public static func lambda(type: Recur, _ f: Recur -> Recur) -> Expression {
		var n = 0
		let body = f(Recur { .Variable(.Local(n)) })
		n = body.out.maxBoundVariable + 1
		return .Lambda(n, type, body)
	}

	public static func lambda(type1: Recur, _ type2: Recur, _ f: (Recur, Recur) -> Recur) -> Expression {
		return lambda(type1) { a in Recur.lambda(type2) { b in f(a, b) } }
	}

	public static func lambda(type1: Recur, _ type2: Recur, _ type3: Recur, _ f: (Recur, Recur, Recur) -> Recur) -> Expression {
		return lambda(type1) { a in Recur.lambda(type2) { b in Recur.lambda(type3) { c in f(a, b, c) } } }
	}

	public static func lambda(type1: Recur, _ type2: Recur, _ type3: Recur, _ type4: Recur, _ f: (Recur, Recur, Recur, Recur) -> Recur) -> Expression {
		return lambda(type1) { a in Recur.lambda(type2) { b in Recur.lambda(type3) { c in Recur.lambda(type4) { d in f(a, b, c, d) } } } }
	}


	// MARK: Destructuring accessors

	var destructured: Expression<Expression<Recur>> {
		return map { $0.out }
	}

	public var isType: Bool {
		return analysis(ifType: const(true), otherwise: { returnType?.out.isType ?? false })
	}

	public var lambda: (Int, Recur, Recur)? {
		return analysis(ifLambda: Optional.Some, otherwise: const(nil))
	}

	public var parameterType: Recur? {
		return lambda?.1
	}

	public var returnType: Recur? {
		return inferType([:], [:]).right?.lambda?.2
	}

	public var product: (Recur, Recur)? {
		return analysis(ifProduct: Optional.Some, ifAnnotation: { $0.0.out.product }, otherwise: const(nil))
	}

	public var boolean: Bool? {
		return analysis(ifBoolean: Optional.Some, otherwise: const(nil))
	}


	// MARK: Variables

	var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: max,
				ifLambda: { max($0.0, $0.1) },
				ifProjection: { $0.0 },
				ifProduct: max,
				ifIf: { max($0, $1, $2) },
				ifAnnotation: max,
				otherwise: const(-1))
		} (Recur(self))
	}

	public var freeVariables: Set<Int> {
		return cata {
			$0.analysis(
				ifVariable: { $0.local.map { [ $0 ] } ?? Set() },
				ifApplication: uncurry(Set.union),
				ifLambda: { $1.union($2.subtract([ $0 ])) },
				ifProjection: { $0.0 },
				ifProduct: uncurry(Set.union),
				ifIf: { $0.union($1).union($2) },
				ifAnnotation: uncurry(Set.union),
				otherwise: const(Set()))
		} (Recur(self))
	}


	// MARK: Weak-head normal form

	public func weakHeadNormalForm(environment: Environment, shouldRecur: Bool = true) -> Expression {
		var visited: Set<Name> = []
		return weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
	}

	public func weakHeadNormalForm(environment: Environment, shouldRecur: Bool = true, inout visited: Set<Name>) -> Expression {
		let unfold: Expression -> Expression = {
			$0.weakHeadNormalForm(environment, shouldRecur: shouldRecur, visited: &visited)
		}
		let done: Expression -> Expression = {
			$0.weakHeadNormalForm(environment, shouldRecur: false, visited: &visited)
		}
		switch destructured {
		case let .Variable(name) where shouldRecur && !visited.contains(name):
			visited.insert(name)
			return environment[name].map(done) ?? self

		case let .Variable(name) where !visited.contains(name):
			visited.insert(name)
			return environment[name] ?? self

		case let .Application(t1, t2):
			let t1 = unfold(t1)
			switch t1 {
			case let .Lambda(i, _, body):
				return unfold(body.out.substitute(i, t2))

			case let .Variable(name) where shouldRecur:
				visited.insert(name)
				let t2 = unfold(t2)
				return environment[name].map { .Application(Recur($0), Recur(t2)) }.map(done) ?? .Application(Recur(t1), Recur(t2))

			default:
				return .Application(Recur(t1), Recur(t2))
			}

		case let .Projection(a, b):
			let a = unfold(a)
			switch a {
			case let .Product(t1, t2):
				return unfold(b ? t1.out : t2.out)

			default:
				return .Projection(Recur(a), b)
			}

		case let .If(condition, then, `else`):
			let condition = unfold(condition)
			switch condition {
			case let .Boolean(flag):
				return unfold(flag ? then : `else`)

			default:
				return .If(Recur(condition), Recur(then), Recur(`else`))
			}

		default:
			return self
		}
	}
}


private func atModular<C: CollectionType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	return collection[advance(collection.startIndex, offset % distance(collection.startIndex, collection.endIndex), collection.endIndex)]
}


import Prelude
