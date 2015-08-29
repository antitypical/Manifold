//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Expression<Recur>: CustomDebugStringConvertible, CustomStringConvertible, IntegerLiteralConvertible, StringLiteralConvertible {
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
		@noescape ifAnnotation: (Recur, Recur) -> T,
		@noescape ifEnumeration: Int -> T,
		@noescape ifTag: (Int, Int) -> T,
		@noescape ifSwitch: (Recur, [Recur]) -> T) -> T {
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
		case let .Annotation(term, type):
			return ifAnnotation(term, type)
		case let .Enumeration(n):
			return ifEnumeration(n)
		case let .Tag(n, m):
			return ifTag(n, m)
		case let .Switch(tag, labels):
			return ifSwitch(tag, labels)
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
		ifAnnotation: ((Recur, Recur) -> T)? = nil,
		ifEnumeration: (Int -> T)? = nil,
		ifTag: ((Int, Int) -> T)? = nil,
		ifSwitch: ((Recur, [Recur]) -> T)? = nil,
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
			ifAnnotation: { ifAnnotation?($0) ?? otherwise() },
			ifEnumeration: { ifEnumeration?($0) ?? otherwise() },
			ifTag: { ifTag?($0) ?? otherwise() },
			ifSwitch: { ifSwitch?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifUnit: const(.Unit),
			ifUnitType: const(.UnitType),
			ifType: { .Type($0) },
			ifVariable: Expression<T>.Variable,
			ifApplication: { .Application(transform($0), transform($1)) },
			ifLambda: { .Lambda($0, transform($1), transform($2)) },
			ifProjection: { .Projection(transform($0), $1) },
			ifProduct: { .Product(transform($0), transform($1)) },
			ifAnnotation: { .Annotation(transform($0), transform($1)) },
			ifEnumeration: Expression<T>.Enumeration,
			ifTag: Expression<T>.Tag,
			ifSwitch: { .Switch(transform($0), $1.map(transform)) })
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
		case let .Annotation(a, b):
			return ".Annotation(\(String(reflecting: a)), \(String(reflecting: b)))"
		case let .Enumeration(n):
			return ".Enumeration(\(n))"
		case let .Tag(t, u):
			return ".Tag(\(t), \(u))"
		case let .Switch(tag, labels):
			let	l = labels.lazy.map { String(reflecting: $0) }.joinWithSeparator(", ")
			return ".Switch(\(tag), [ \(l) ])"
		}
	}


	// MARK: CustomStringConvertible

	public var description: String {
		let renderNumerals: (Int, String) -> String = { n, alphabet in
			n.digits(alphabet.characters.count).lazy.map { String(atModular(alphabet.characters, offset: $0)) }.joinWithSeparator("")
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

		case let .Annotation(term, type):
			return "\(term) : \(type)"

		case let .Enumeration(n):
			return "@\(n)"
		case let .Tag(m, n):
			return "#{\(m) of \(n)}"
		case let .Switch(tag, labels):
			let l = labels.lazy.map { String($0) }.joinWithSeparator(",\n\t")
			return "case \(tag) of [\n\t\(l)\n]"
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
	case Annotation(Recur, Recur)
	case Enumeration(Int) // n-point domain
	case Tag(Int, Int) // a point x in an n-point domain
	case Switch(Recur, [Recur]) // select one of n points
}

extension Expression where Recur: TermType {
	// MARK: First-order construction

	/// Constructs a (non-dependent) function type from `A` to `B`.
	public static func FunctionType(a: Recur, _ b: Recur) -> Expression {
		return .Lambda(-1, a, b)
	}

	/// Constructs a (non-dependent) function type from `A` to `B` to `C`.
	public static func FunctionType(a: Recur, _ b: Recur, _ c: Recur) -> Expression {
		return .FunctionType(a, .FunctionType(b, c))
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


	// MARK: Variables

	var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: max,
				ifLambda: { max($0.0, $0.1) },
				ifProjection: { $0.0 },
				ifProduct: max,
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

		default:
			return self
		}
	}
}


private func atModular<C: CollectionType>(collection: C, offset: C.Index.Distance) -> C.Generator.Element {
	return collection[collection.startIndex.advancedBy(offset % collection.startIndex.distanceTo(collection.endIndex), limit: collection.endIndex)]
}


import Prelude
