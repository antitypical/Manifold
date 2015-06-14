//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: CustomDebugStringConvertible, FixpointType, Hashable, CustomStringConvertible {
	public init(_ expression: Checkable<Term>) {
		self._expression = Box(expression)
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
		return Term(.Application(a, b))
	}


	public static func projection(a: Term, _ b: Bool) -> Term {
		return Term(.Projection(a, b))
	}


	public static func bound(i: Int) -> Term {
		return Term(.Bound(i))
	}

	public static func free(name: Name) -> Term {
		return Term(.Free(name))
	}


	public static func pi(type: Term, _ body: Term) -> Term {
		return Term(.Pi(type, body))
	}

	public static func sigma(type: Term, _ body: Term) -> Term {
		return Term(.Sigma(type, body))
	}


	public static var booleanType: Term {
		return Term(.BooleanType)
	}

	public static func boolean(b: Bool) -> Term {
		return Term(.Boolean(b))
	}


	// MARK: Destructors

	public var isUnitTerm: Bool {
		return expression.analysis(
			ifUnit: const(true),
			otherwise: const(false))
	}

	public var isUnitType: Bool {
		return expression.analysis(
			ifUnitType: const(true),
			otherwise: const(false))
	}

	public var isType: Bool {
		return expression.analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var bound: Int? {
		return expression.analysis(
			ifBound: pure,
			otherwise: const(nil))
	}

	public var application: (Term, Term)? {
		return expression.analysis(
			ifApplication: pure,
			otherwise: const(nil))
	}

	public var pi: (Term, Term)? {
		return expression.analysis(
			ifPi: pure,
			otherwise: const(nil))
	}

	public var sigma: (Term, Term)? {
		return expression.analysis(
			ifSigma: pure,
			otherwise: const(nil))
	}

	private var _expression: Box<Checkable<Term>>
	public var expression: Checkable<Term> {
		return _expression.value
	}


	// MARK: Normalization

	public var isNormalForm: Bool {
		return expression.analysis(
			ifBound: const(false),
			ifFree: const(false),
			ifApplication: const(false),
			ifProjection: const(false),
			otherwise: const(true))
	}


	// MARK: Substitution

	public func substitute(i: Int, _ term: Term) -> Term {
		return expression.analysis(
			ifBound: { i == $0 ? term : self },
			ifApplication: { Term.application($0.substitute(i, term), $1.substitute(i, term)) },
			ifPi: { Term.pi($0.substitute(i, term), $1.substitute(i + 1, term)) },
			ifProjection: { Term.projection($0.substitute(i, term), $1) },
			ifSigma: { Term.sigma($0.substitute(i, term), $1.substitute(i + 1, term)) },
			otherwise: const(self))
	}


	// MARK: Type-checking

	public func typecheck() -> Either<Error, Term> {
		return typecheck([:], from: 0)
	}

	public func typecheck(context: Context, from i: Int) -> Either<Error, Term> {
		return expression.analysis(
			ifUnit: const(.right(.unitType)),
			ifUnitType: const(.right(.type)),
			ifType: { .right(.type($0 + 1)) },
			ifBound: { i -> Either<Error, Term> in
				context[.Local(i)].map(Either.right)
					?? Either.left("unexpectedly free bound variable \(i)")
			},
			ifFree: { i -> Either<Error, Term> in
				context[i]
					.map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Term> in
				a.typecheck(context, from: i)
					.flatMap { t in
						t.expression.analysis(
							ifPi: { v, f in
								b.typecheck(context, against: v, from: i)
									.map { f.substitute(i, $0) }
							},
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
				}
			},
			ifPi: { t, b -> Either<Error, Term> in
				t.typecheck(context, from: i)
					.flatMap { _ in
						let t = t.evaluate()
						return b.substitute(0, .free(.Local(i))).typecheck([ .Local(i): t ] + context, from: i + 1)
							.map { Term.pi(t, $0) }
					}
			},
			ifProjection: { a, b -> Either<Error, Term> in
				a.typecheck(context, from: i)
					.flatMap { t in
						t.expression.analysis(
							ifSigma: { v, f in Either.right(b ? f.substitute(i, v) : v) },
							otherwise: const(Either.left("illegal projection of \(a) : \(t) field \(b ? 1 : 0)")))
					}
			},
			ifSigma: { a, b -> Either<Error, Term> in
				a.typecheck(context, from: i)
					.flatMap { _ in
						let t = a.evaluate()
						return b.substitute(0, .free(.Local(i))).typecheck([ .Local(i): t ] + context, from: i + 1)
							.map { Term.sigma(t, $0) }
					}
			},
			ifBooleanType: const(.right(.type)),
			ifBoolean: const(.right(.booleanType)))
	}

	public func typecheck(context: Context, against: Term, from i: Int) -> Either<Error, Term> {
		return typecheck(context, from: i)
			.flatMap { t in
				(t == against) || (against == .type && t == Term.pi(.type, .type))
					? Either.right(t)
					: Either.left("type mismatch: expected (\(String(reflecting: self))) : (\(String(reflecting: against))), actually (\(String(reflecting: self))) : (\(String(reflecting: t))) in environment \(context)")
			}
	}


	// MARK: Evaluation

	public func evaluate(environment: Environment = Environment()) -> Term {
		return expression.analysis(
			ifUnit: const(self),
			ifUnitType: const(self),
			ifType: const(self),
			ifBound: { i -> Term in
				environment.local[i]
			},
			ifFree: { i -> Term in
				environment.global[i] ?? .free(i)
			},
			ifApplication: { a, b -> Term in
				a.evaluate(environment).substitute(0, b.evaluate(environment))
			},
			ifPi: const(self),
			ifProjection: { a, b -> Term in
				a.evaluate(environment).sigma.map { b ? $1 : $0 }!
			},
			ifSigma: const(self),
			ifBooleanType: const(self),
			ifBoolean: const(self))
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Checkable<String>) -> String {
		return expression.analysis(
			ifUnit: const("()"),
			ifUnitType: const("Unit"),
			ifType: { "Type\($0)" },
			ifBound: { "Bound(\($0))" },
			ifFree: { "Free(\($0))" },
			ifApplication: { "\($0)(\($1))" },
			ifPi: { "Π \($0) . \($1)" },
			ifProjection: { "\($0).\($1 ? 1 : 0)" },
			ifSigma: { "Σ \($0) . \($1)" },
			ifBooleanType: const("Boolean"),
			ifBoolean: { String(reflecting: $0) })
	}


	// MARK: FixpointType

	public var out: Checkable<Term> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		return expression.analysis(
			ifUnit: const(0),
			ifUnitType: const(1),
			ifType: { 2 ^ $0.hashValue },
			ifBound: { 3 ^ $0.hashValue },
			ifFree: { 5 ^ $0.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue },
			ifProjection: { 13 ^ $0.hashValue ^ $1.hashValue },
			ifSigma: { 17 ^ $0.hashValue ^ $1.hashValue },
			ifBooleanType: const(19),
			ifBoolean: { 23 ^ $0.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Checkable<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.String(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifUnit: const("()"),
			ifUnitType: const("Unit"),
			ifType: { $0 > 0 ? "Type\($0)" : "Type" },
			ifBound: alphabetize,
			ifFree: { $0.analysis(ifGlobal: id, ifLocal: alphabetize, ifQuote: alphabetize) },
			ifApplication: { "\($0.1)(\($1.1))" },
			ifPi: {
				"Π : \($0.1) . \($1.1)"
			},
			ifProjection: {
				"\($0.1).\($1 ? 1 : 0)"
			},
			ifSigma: {
				"Σ \($0.1) . \($1.1)"
			},
			ifBooleanType: const("Boolean"),
			ifBoolean: { String($0) })
	}
}


private func pure<T>(x: T) -> T? {
	return x
}


import Box
import Either
import Prelude
