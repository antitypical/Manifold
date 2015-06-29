//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: BooleanLiteralConvertible, CustomDebugStringConvertible, FixpointType, Hashable, IntegerLiteralConvertible, CustomStringConvertible {
	public init(_ expression: Inferable<Term>) {
		self.init { expression }
	}

	public init(_ expression: () -> Inferable<Term>) {
		_expression = expression
	}


	// MARK: Constructors

	public static var unit: Term {
		return Term(.Unit)
	}

	public static var unitType: Term {
		return Term(.UnitType)
	}


	public static var type: Term {
		return Term(.Type(0))
	}

	public static func type(n: Int) -> Term {
		return Term(.Type(n))
	}


	public static func application(a: Term, _ b: Term) -> Term {
		return application(a, .Inferable(b))
	}

	public static func application(a: Term, _ b: Checkable<Term>) -> Term {
		return Term(.Application(a, b))
	}


	public static func projection(a: Term, _ b: Bool) -> Term {
		return Term(.Projection(a, b))
	}


	public static func variable(name: Name) -> Term {
		return Term(.Variable(name))
	}


	public static func lambda(variable: Int, _ type: Term, _ body: Term) -> Term {
		return lambda(variable, .Inferable(type), .Inferable(body))
	}

	public static func lambda(variable: Int, _ type: Checkable<Term>, _ body: Checkable<Term>) -> Term {
		return Term(.Lambda(variable, type, body))
	}

	public static func sigma(variable: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Sigma(variable, type, body))
	}


	public static func sum(a: Term, _ b: Term) -> Term {
		return sigma(booleanType) { c in `if`(c, then: a, `else`: b) }
	}

	public static func sum(terms: [Term]) -> Term {
		return terms.first.map { dropFirst(terms).reduce($0, combine: sum) } ?? unitType
	}


	public static var booleanType: Term {
		return Term(.BooleanType)
	}

	public static func boolean(b: Bool) -> Term {
		return Term(.Boolean(b))
	}

	public static func `if`(condition: Term, then: Term, `else`: Term) -> Term {
		return Term(.If(condition, then, `else`))
	}


	// MARK: Higher-order construction

	public static func lambda(type: Term, _ f: Term -> Term) -> Term {
		return lambda(.Inferable(type), f)
	}

	public static func lambda(type: Checkable<Term>, _ f: Term -> Term) -> Term {
		var n = 0
		let body = f(Term { .Variable(.Local(n)) })
		n = body.maxBoundVariable + 1
		return Term { .Lambda(n, type, .Inferable(body)) }
	}

	public static func sigma(type: Term, _ f: Term -> Term) -> Term {
		var n = 0
		let body = f(Term { .Variable(.Local(n)) })
		n = body.maxBoundVariable + 1
		return Term { .Sigma(n, type, body) }
	}


	// MARK: Destructors

	public var isUnitTerm: Bool {
		return expression.analysis(ifUnit: const(true), otherwise: const(false))
	}

	public var isUnitType: Bool {
		return expression.analysis(ifUnitType: const(true), otherwise: const(false))
	}

	public var isType: Bool {
		return expression.analysis(ifType: const(true), otherwise: const(false))
	}

	public var application: (Term, Checkable<Term>)? {
		return expression.analysis(ifApplication: Optional.Some, otherwise: const(nil))
	}

	public var lambda: (Int, Checkable<Term>, Checkable<Term>)? {
		return expression.analysis(ifLambda: Optional.Some, otherwise: const(nil))
	}

	public var sigma: (Int, Term, Term)? {
		return expression.analysis(ifSigma: Optional.Some, otherwise: const(nil))
	}

	public var boolean: Bool? {
		return expression.analysis(ifBoolean: Optional.Some, otherwise: const(nil))
	}

	private var _expression: () -> Inferable<Term>
	public var expression: Inferable<Term> {
		return _expression()
	}


	// MARK: Normalization

	public var isNormalForm: Bool {
		return expression.analysis(
			ifApplication: const(false),
			ifProjection: const(false),
			ifIf: const(false),
			ifAnnotation: const(false),
			otherwise: const(true))
	}


	// MARK: Bound variables

	private var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: { max($0, $1.analysis(ifInferable: id)) },
				ifLambda: { max($0.0, $0.1.analysis(ifInferable: id)) },
				ifProjection: { $0.0 },
				ifSigma: { max($0.0, $0.1) },
				ifIf: { max($0, $1, $2) },
				ifAnnotation: { max($0.analysis(ifInferable: id), $1.analysis(ifInferable: id)) },
				otherwise: const(-1))
		} (self)
	}


	// MARK: Substitution

	private func substitute(i: Int, _ term: Term) -> Term {
		return cata { t in
			t.analysis(
				ifVariable: {
					$0.analysis(
						ifGlobal: const(Term(t)),
						ifLocal: { $0 == i ? term : Term.variable(.Local($0)) })
				},
				ifApplication: Term.application,
				ifLambda: Term.lambda,
				ifProjection: Term.projection,
				ifSigma: Term.sigma,
				ifIf: Term.`if`,
				otherwise: const(Term(t)))
		} (self)
	}


	// MARK: Type-checking

	public func typecheck(environment: [Name: Term] = [:]) -> Either<Error, Term> {
		switch expression {
		case .Unit:
			return .right(.unitType)
		case .UnitType, .BooleanType:
			return .right(.type)
		case let .Type(n):
			return .right(.type(n + 1))
		case let .Variable(i):
			return environment[i].map(Either.right) ?? Either.left("unexpectedly free variable \(i)")
		case let .Application(a, b):
			return a.typecheck(environment)
				.flatMap { t in
					t.expression.analysis(
						ifLambda: { i, v, f in
							v.analysis(ifInferable: { v in
								f.analysis(ifInferable: { f in
									b.analysis(ifInferable: { $0.typecheck(environment, against: v) }).map { f.substitute(i, $0) }
								})
							})
						},
						otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
				}
		case let .Lambda(i, t, b):
			return t.analysis(ifInferable: { t in
				t.typecheck(environment)
					.flatMap { _ in
						b.analysis(ifInferable: { b in
							b.typecheck(environment + [ .Local(i): t ])
								.map { Term.lambda(t, const($0)) }
						})
					}
			})
		case let .Projection(a, b):
			return a.typecheck(environment)
				.flatMap { t in
					t.expression.analysis(
						ifSigma: { i, v, f in Either.right(b ? f.substitute(i, v) : v) },
						otherwise: const(Either.left("illegal projection of \(a) : \(t) field \(b ? 1 : 0)")))
				}
		case let .Sigma(i, a, b):
			return a.typecheck(environment)
				.flatMap { a in
					let t = a.evaluate()
					return b.typecheck(environment + [ .Local(i): t ])
						.map { Term.sigma(t, const($0)) }
				}
		case .Boolean:
			return .right(.booleanType)
		case let .If(condition, then, `else`):
			return condition.typecheck(environment, against: .booleanType)
				.flatMap { _ in
					(then.typecheck(environment) &&& `else`.typecheck(environment))
						.map { a, b in
							a == b
								? a
								: Term.sigma(.booleanType) { Term.`if`($0, then: a, `else`: b) }
						}
				}
		case let .Annotation(term, type):
			return type.analysis(ifInferable: {
				$0.typecheck(environment, against: Term.type)
					.map { $0.evaluate() }
					.flatMap { type in term.analysis(ifInferable: { $0.typecheck(environment, against: type) }) }
			})
		}
	}

	public func typecheck(environment: [Name: Term], against: Term) -> Either<Error, Term> {
		return typecheck(environment)
			.flatMap { t in
				(t == against) || (against == .type && t == Term.lambda(.type, const(.type)))
					? Either.right(t)
					: Either.left("type mismatch: expected (\(String(reflecting: self))) : (\(String(reflecting: against))), actually (\(String(reflecting: self))) : (\(String(reflecting: t))) in environment \(environment)")
			}
	}


	// MARK: Evaluation

	public func evaluate(environment: [Name: Term] = [:]) -> Term {
		switch expression {
		case let .Variable(i):
			return environment[i] ?? .variable(i)
		case let .Application(a, b):
			return a.evaluate(environment).lambda.map { i, type, body in body.analysis(ifInferable: { $0.substitute(i, b.analysis(ifInferable: { $0.evaluate(environment) })) }) }!
		case let .Projection(a, b):
			return a.evaluate(environment).sigma.map { b ? $2 : $1 }!
		case let .If(condition, then, `else`):
			return condition.evaluate(environment).boolean!
				? then.evaluate(environment)
				: `else`.evaluate(environment)
		case let .Annotation(term, _):
			return term.analysis(ifInferable: { $0.evaluate(environment) })
		default:
			return self
		}
	}


	// MARK: BooleanLiteralConvertible

	public init(booleanLiteral value: Bool) {
		self = Term.boolean(value)
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Inferable<String>) -> String {
		return expression.analysis(
			ifUnit: const("()"),
			ifUnitType: const("Unit"),
			ifType: { "Type\($0)" },
			ifVariable: { "Variable(\($0))" },
			ifApplication: { "\($0)(\($1))" },
			ifLambda: { "λ \($0) : \($1.analysis(ifInferable: id)) . \($2.analysis(ifInferable: id))" },
			ifProjection: { "\($0).\($1 ? 1 : 0)" },
			ifSigma: { "Σ \($0) : \($1) . \($2)" },
			ifBooleanType: const("Boolean"),
			ifBoolean: { String(reflecting: $0) },
			ifIf: { "if \($0) then \($1) else \($2)" },
			ifAnnotation: { "\($0.analysis(ifInferable: id)) : \($1.analysis(ifInferable: id))" })
	}


	// MARK: FixpointType

	public var out: Inferable<Term> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		let hash: Checkable<Int> -> Int = {
			$0.analysis(ifInferable: id)
		}
		return cata {
			$0.analysis(
				ifUnit: { 1 },
				ifUnitType: { 2 },
				ifType: { 3 ^ $0 },
				ifVariable: { 5 ^ $0.hashValue },
				ifApplication: { 7 ^ $0 ^ hash($1) },
				ifLambda: { 11 ^ $0 ^ hash($1) ^ hash($2) },
				ifProjection: { 13 ^ $0 ^ $1.hashValue },
				ifSigma: { 17 ^ $0 ^ $1 ^ $2 },
				ifBooleanType: { 19 },
				ifBoolean: { 23 ^ $0.hashValue },
				ifIf: { 29 ^ $0 ^ $1 ^ $2 },
				ifAnnotation: { 31 ^ hash($0) ^ hash($1) })
		} (self)
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self = Term.variable(.Local(value))
	}


	// MARK: Printable

	public var description: String {
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Inferable<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.String(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifUnit: const("()"),
			ifUnitType: const("Unit"),
			ifType: { $0 > 0 ? "Type\($0)" : "Type" },
			ifVariable: { $0.analysis(ifGlobal: id, ifLocal: alphabetize) },
			ifApplication: { "\($0.1)(\($1.analysis(ifInferable: id)))" },
			ifLambda: {
				"λ \(alphabetize($0)) : \($1.analysis(ifInferable: { $0.1 })) . \($2.analysis(ifInferable: { $0.1 }))"
			},
			ifProjection: {
				"\($0.1).\($1 ? 1 : 0)"
			},
			ifSigma: {
				"Σ \(alphabetize($0)) : \($1.1) . \($2.1)"
			},
			ifBooleanType: const("Boolean"),
			ifBoolean: { String($0) },
			ifIf: { "if \($0) then \($1) else \($2)" },
			ifAnnotation: { "\($0.analysis(ifInferable: id)) : \($1.analysis(ifInferable: id))" })
	}
}


import Either
import Prelude
