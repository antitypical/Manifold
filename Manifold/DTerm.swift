//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: DExpression<DTerm>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var kind: DTerm {
		return DTerm(.Kind)
	}

	public static var type: DTerm {
		return DTerm(.Type)
	}


	public static func application(a: DTerm, _ b: DTerm) -> DTerm {
		return DTerm(.Application(Box(a), Box(b)))
	}


	public static func lambda(type: DTerm, _ f: DTerm -> DTerm) -> DTerm {
		let body = f(variable(-1))
		let (n, build) = repMax(DTerm.pi(-1, type, body))
		return build(Box(variable(n + 1)))
	}

	public static func pair(type: DTerm, _ f: DTerm -> DTerm) -> DTerm {
		let body = f(variable(-1))
		let (n, build) = repMax(DTerm.sigma(-1, type, body))
		return build(Box(variable(n + 1)))
	}

	private static func variable(i: Int) -> DTerm {
		return DTerm(.Variable(i))
	}

	private static func pi(variable: Int, _ type: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Pi(variable, Box(type), Box(body)))
	}

	private static func sigma(variable: Int, _ type: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Sigma(variable, Box(type), Box(body)))
	}

	private static func repMax(term: DTerm) -> (Int, Box<DTerm> -> DTerm) {
		return term.expression.analysis(
			ifKind: const(-3, const(term)),
			ifType: const(-2, const(term)),
			ifVariable: { i in
				return (i, const(term))
			},
			ifApplication: { a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(ma, mb), { DTerm(.Application(Box(builda($0)), Box(buildb($0)))) })
			},
			ifPi: { i, t, b in
				let (mt, buildt) = repMax(t)
				let (mb, buildb) = repMax(b)
				return (max(i, mt, mb), { DTerm(.Pi(i, Box(buildt($0)), Box(buildb($0)))) })
			},
			ifSigma: { i, a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(i, ma, mb), { DTerm(.Sigma(i, Box(builda($0)), Box(buildb($0)))) })
			})
	}


	// MARK: Destructors

	public var isKind: Bool {
		return expression.analysis(
			ifKind: const(true),
			otherwise: const(false))
	}

	public var isType: Bool {
		return expression.analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var variable: Int? {
		return expression.analysis(
			ifVariable: unit,
			otherwise: const(nil))
	}

	public var application: (DTerm, DTerm)? {
		return expression.analysis(
			ifApplication: unit,
			otherwise: const(nil))
	}

	public var pi: (Int, DTerm, DTerm)? {
		return expression.analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (Int, DTerm, DTerm)? {
		return expression.analysis(
			ifSigma: unit,
			otherwise: const(nil))
	}

	public let expression: DExpression<DTerm>


	// MARK: Type-checking

	public var freeVariables: Set<Int> {
		return expression.analysis(
			ifVariable: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifPi: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			ifSigma: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			otherwise: const([]))
	}

	public enum Sort: BidirectionalIndexType, Comparable, Printable {
		case Term
		case Type
		case Kind


		// MARK: BidirectionalIndexType

		public func predecessor() -> Sort {
			switch self {
			case .Kind:
				return .Type
			default:
				return .Term
			}
		}


		// MARK: ForwardIndexType

		public func successor() -> Sort {
			switch self {
			case .Term:
				return .Type
			default:
				return .Kind
			}
		}


		// MARK: Printable

		public var description: String {
			switch self {
			case .Term:
				return "Term"
			case .Type:
				return "Type"
			case .Kind:
				return "Kind"
			}
		}
	}

	public func sort(environment: [Int: DTerm]) -> Sort {
		return expression.analysis(
			ifKind: const(.Kind),
			ifType: const(.Type),
			ifVariable: { environment[$0]?.sort(environment) ?? .Kind },
			ifApplication: { $1.sort(environment) },
			ifPi: { $2.sort(environment + [$0: $1]) },
			ifSigma: { $2.sort(environment + [$0: $1]) })
	}

	public func typecheck() -> Either<Error, DTerm> {
		return typecheck([])
	}

	private func typecheck(environment: Multiset<Binding>) -> Either<Error, DTerm> {
		return expression.analysis(
			ifKind: const(Either.right(self)),
			ifType: const(Either.right(self)),
			ifVariable: { i -> Either<Error, DTerm> in
				find(environment) { $0.variable == i }
					.flatMap { environment[$0] }
					.map { Either.right($0.value) }
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { abs, arg -> Either<Error, DTerm> in
				(abs.typecheck(environment)
					.flatMap { $0.evaluate(environment) }
					.flatMap { $0.pi != nil ? Either.right($0) : Either.left("cannot apply \(abs) : \($0) to \(arg)") } &&& arg.typecheck(environment)).map(DTerm.application)
			},
			ifPi: { i, type, body -> Either<Error, DTerm> in
				(type.typecheck(environment) &&& body.typecheck(environment.union([ Binding(i, type) ])))
					.map { t, b in DTerm.lambda(t) { _ in b.substitute(t, forVariable: i) } }
			},
			ifSigma: { i, type, body -> Either<Error, DTerm> in
				(type.typecheck(environment) &&& body.typecheck(environment.union([ Binding(i, type) ])))
					.map { t, b in DTerm.pair(t) { _ in b.substitute(t, forVariable: i) } }
			})
	}

	private struct Binding: Hashable {
		init(_ variable: Int, _ value: DTerm) {
			self.variable = variable
			self.value = value
		}

		let variable: Int
		let value: DTerm

		var hashValue: Int {
			return variable & value.hashValue
		}
	}


	// MARK: Substitution

	public func substitute(value: DTerm, forVariable i: Int) -> DTerm {
		return expression.analysis(
			ifKind: const(self),
			ifType: const(self),
			ifVariable: { $0 == i ? value : DTerm.variable($0) },
			ifApplication: { DTerm.application($0.substitute(value, forVariable: i), $1.substitute(value, forVariable: i)) },
			ifPi: { DTerm.pi($0, $1.substitute(value, forVariable: i), $2.substitute(value, forVariable: i)) },
			ifSigma: { DTerm.sigma($0, $1.substitute(value, forVariable: i), $2.substitute(value, forVariable: i)) })
	}


	// MARK: Evaluation

	public var isValue: Bool {
		return expression.analysis(
			ifApplication: const(false),
			otherwise: const(true))
	}

	public func evaluate() -> Either<Error, DTerm> {
		return evaluate([])
	}

	private func evaluate(environment: Multiset<Binding>) -> Either<Error, DTerm> {
		return
			typecheck(environment)
			.flatMap { _ in
				self.expression.analysis(
					ifApplication: {
						($0.evaluate(environment) &&& $1.evaluate(environment)).map { abs, arg in
							abs.pi.map { $2.substitute(arg, forVariable: $0) }!
						}
					},
					otherwise: const(Either.right(self)))
			}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return expression.debugDescription
	}


	// MARK: FixpointType

	public var out: DExpression<DTerm> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		return expression.analysis(
			ifKind: { 2 },
			ifType: { 3 },
			ifVariable: { 5 ^ $0.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue ^ $2.hashValue },
			ifSigma: { 13 ^ $0.hashValue ^ $1.hashValue ^ $2.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return para(DTerm.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: DExpression<(DTerm, String)>) -> String {
		return expression.analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { index in
				Swift.toString(alphabet[advance(alphabet.startIndex, index)])
			},
			ifApplication: { "(\($0.1)) (\($1.1))" },
			ifPi: {
				$2.0.freeVariables.contains($0)
					? "∏ \($0) : \($1.1) . \($2.1)"
					: "(\($1.1)) → \($2.1)"
			},
			ifSigma: {
				$2.0.freeVariables.contains($0)
					? "∑ \($0) : \($1.1) . \($2.1)"
					: "(\($1.1) ✕ \($2.1))"
			})
	}
}

public enum DExpression<Recur>: DebugPrintable {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifVariable: Int -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifPi: (Int, Recur, Recur) -> T,
		@noescape ifSigma: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Variable(x):
			return ifVariable(x)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Pi(i, a, b):
			return ifPi(i, a.value, b.value)
		case let .Sigma(i, a, b):
			return ifSigma(i, a.value, b.value)
		}
	}

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifVariable: (Int -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifPi: ((Int, Recur, Recur) -> T)? = nil,
		ifSigma: ((Int, Recur, Recur) -> T)? = nil,
		otherwise: () -> T) -> T {
		return analysis(
			ifKind: { ifKind?() ?? otherwise() },
			ifType: { ifType?() ?? otherwise() },
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> DExpression<T> {
		return analysis(
			ifKind: { .Kind },
			ifType: { .Type },
			ifVariable: { .Variable($0) },
			ifApplication: { .Application(Box(transform($0)), Box(transform($1))) },
			ifPi: { .Pi($0, Box(transform($1)), Box(transform($2))) },
			ifSigma: { .Sigma($0, Box(transform($1)), Box(transform($2))) })
	}


	// MARK: Cases

	case Kind
	case Type
	case Variable(Int)
	case Application(Box<Recur>, Box<Recur>)
	case Pi(Int, Box<Recur>, Box<Recur>) // (∏x:A)B where B can depend on x
	case Sigma(Int, Box<Recur>, Box<Recur>) // (∑x:A)B where B can depend on x


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { "\($0)" },
			ifApplication: { "(\($0)) (\($1))" },
			ifPi: { "∏ \($0) : \($1) . \($2)" },
			ifSigma: { "∑ \($0) : \($1) . \($2)" })
	}
}


private func == (left: DTerm.Binding, right: DTerm.Binding) -> Bool {
	return left.variable == right.variable && left.value == right.value
}


import Box
import Either
import Prelude
import Set
