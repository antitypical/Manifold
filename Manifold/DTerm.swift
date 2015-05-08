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
		let body = f(lambdaPlaceholder)
		let (n, build) = repMax(DTerm.pi(lambdaPlaceholder, body))
		return build(Box(variable(n + 1, type)))
	}

	public static func pair(type: DTerm, _ f: DTerm -> DTerm) -> DTerm {
		let body = f(lambdaPlaceholder)
		let (n, build) = repMax(DTerm.sigma(lambdaPlaceholder, body))
		return build(Box(variable(n + 1, type)))
	}

	private static func variable(i: Int, _ type: DTerm) -> DTerm {
		return DTerm(.Variable(i, Box(type)))
	}

	private static func pi(variable: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Pi(Box(variable), Box(body)))
	}

	private static func sigma(variable: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Sigma(Box(variable), Box(body)))
	}

	private static var lambdaPlaceholder = variable(-1, DTerm.kind)

	private static func repMax(term: DTerm) -> (Int, Box<DTerm> -> DTerm) {
		return term.expression.analysis(
			ifKind: const(-3, const(term)),
			ifType: const(-2, const(term)),
			ifVariable: { i, t in
				let (mt, buildt) = repMax(t)
				return (max(i, mt), { DTerm(.Variable(i, t == DTerm.lambdaPlaceholder ? $0 : Box(buildt($0)))) })
			},
			ifApplication: { a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(ma, mb), { DTerm(.Application(a == DTerm.lambdaPlaceholder ? $0 : Box(builda($0)), b == DTerm.lambdaPlaceholder ? $0 : Box(buildb($0)))) })
			},
			ifPi: { t, b in
				let (mt, buildt) = repMax(t)
				let (mb, buildb) = repMax(b)
				return (max(mt, mb), { DTerm(.Pi(t == DTerm.lambdaPlaceholder ? $0 : Box(buildt($0)), b == DTerm.lambdaPlaceholder ? $0 : Box(buildb($0)))) })
			},
			ifSigma: { a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(ma, mb), { DTerm(.Sigma(a == DTerm.lambdaPlaceholder ? $0 : Box(builda($0)), b == DTerm.lambdaPlaceholder ? $0 : Box(buildb($0)))) })
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

	public var variable: (Int, DTerm)? {
		return expression.analysis(
			ifVariable: unit,
			otherwise: const(nil))
	}

	public var application: (DTerm, DTerm)? {
		return expression.analysis(
			ifApplication: unit,
			otherwise: const(nil))
	}

	public var pi: (DTerm, DTerm)? {
		return expression.analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (DTerm, DTerm)? {
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
			ifPi: { $0.freeVariables.union($1.freeVariables).subtract([ $0.variable!.0 ]) },
			ifSigma: { $0.freeVariables.union($1.freeVariables).subtract([ $0.variable!.0 ]) },
			otherwise: const([]))
	}

	public func typecheck() -> Either<Error, DTerm> {
		return typecheck([])
	}

	private func typecheck(environment: Multiset<Binding>) -> Either<Error, DTerm> {
		return expression.analysis(
			ifKind: const(Either.right(self)),
			ifType: const(Either.right(self)),
			ifVariable: { environment.contains(Binding($0, $1)) ? $1.typecheck(environment) : Either.left("unexpected free variable \($0)") },
			ifApplication: { abs, arg in
				(abs.typecheck(environment)
					.flatMap { $0.evaluate(environment) }
					.flatMap { $0.pi != nil ? Either.right($0) : Either.left("cannot apply \(abs) : \($0) to \(arg)") } &&& arg.typecheck(environment)).map(DTerm.application)
			},
			ifPi: { type, body in
				type.variable.map { i, t in
					body.typecheck(environment.union([ Binding(i, t) ]))
						.map { b in DTerm.lambda(t) { x in b.substitute(t, forVariable: type) } }
				}
					?? Either.left("unexpected non-variable parameter type: \(type)")
			},
			ifSigma: { type, body in
				type.variable.map { i, t in
					body.typecheck(environment.union([ Binding(i, t) ]))
						.map { b in DTerm.pair(t) { x in b.substitute(t, forVariable: type) } }
				}
					?? Either.left("unexpected non-variable parameter type: \(type)")
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

	public func substitute(value: DTerm, forVariable variable: DTerm) -> DTerm {
		if self == variable { return value }
		return expression.analysis(
			ifKind: const(self),
			ifType: const(self),
			ifVariable: { DTerm.variable($0, $1.substitute(value, forVariable: variable)) },
			ifApplication: { DTerm.application($0.substitute(value, forVariable: variable), $1.substitute(value, forVariable: variable)) },
			ifPi: { DTerm.pi($0.substitute(value, forVariable: variable), $1.substitute(value, forVariable: variable)) },
			ifSigma: { DTerm.sigma($0.substitute(value, forVariable: variable), $1.substitute(value, forVariable: variable)) })
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
							abs.pi.map { $1.substitute(arg, forVariable: $0) }!
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
			ifVariable: { 5 ^ $0 ^ $1.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue },
			ifSigma: { 13 ^ $0.hashValue ^ $1.hashValue })
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
			ifVariable: { index, type in
				"\(alphabet[advance(alphabet.startIndex, index)]) : \(type.1)"
			},
			ifApplication: { "(\($0.1)) (\($1.1))" },
			ifPi: { param, body in
				let (n, t) = param.0.variable!
				return contains(body.0.freeVariables, n) ? "∏ \(param.1) . \(body.1)" : "(\(t)) → \(body.1)"
			},
			ifSigma: { tag, body in
				let (n, t) = tag.0.variable!
				return contains(body.0.freeVariables, n) ? "∑ \(tag.1) . \(body.1)" : "(\(t) ✕ \(body.1))"
			})
	}
}

public enum DExpression<Recur>: DebugPrintable {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifVariable: (Int, Recur) -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifPi: (Recur, Recur) -> T,
		@noescape ifSigma: (Recur, Recur) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Variable(x, type):
			return ifVariable(x, type.value)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Pi(a, b):
			return ifPi(a.value, b.value)
		case let .Sigma(a, b):
			return ifSigma(a.value, b.value)
		}
	}

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifVariable: ((Int, Recur) -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifPi: ((Recur, Recur) -> T)? = nil,
		ifSigma: ((Recur, Recur) -> T)? = nil,
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
			ifVariable: { .Variable($0, Box(transform($1))) },
			ifApplication: { .Application(Box(transform($0)), Box(transform($1))) },
			ifPi: { .Pi(Box(transform($0)), Box(transform($1))) },
			ifSigma: { .Sigma(Box(transform($0)), Box(transform($1))) })
	}


	// MARK: Cases

	case Kind
	case Type
	case Variable(Int, Box<Recur>)
	case Application(Box<Recur>, Box<Recur>)
	case Pi(Box<Recur>, Box<Recur>) // (∏x:A)B where B can depend on x
	case Sigma(Box<Recur>, Box<Recur>) // (∑x:A)B where B can depend on x


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { "\($0) : \($1)" },
			ifApplication: { "(\($0)) (\($1))" },
			ifPi: { "∏ \($0) . \($1)" },
			ifSigma: { "∑ \($0) . \($1)" })
	}
}


private func == (left: DTerm.Binding, right: DTerm.Binding) -> Bool {
	return left.variable == right.variable && left.value == right.value
}


import Box
import Either
import Prelude
import Set
