//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: Checkable<Term>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var unitTerm: Term {
		return Term(.UnitTerm)
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
		return Term(.Application(Box(a), Box(b)))
	}


	public static func projection(a: Term, _ b: Bool) -> Term {
		return Term(.Projection(Box(a), b))
	}


	public static func bound(i: Int) -> Term {
		return Term(.Bound(i))
	}

	public static func free(name: Name) -> Term {
		return Term(.Free(name))
	}


	public static func pi(type: Term, _ body: Term) -> Term {
		return Term(.Pi(Box(type), Box(body)))
	}

	public static func sigma(type: Term, _ body: Term) -> Term {
		return Term(.Sigma(Box(type), Box(body)))
	}


	// MARK: Destructors

	public var isUnitTerm: Bool {
		return expression.analysis(
			ifUnitTerm: const(true),
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

	public let expression: Checkable<Term>


	// MARK: Substitution

	public func substitute(i: Int, _ term: Term) -> Term {
		return expression.analysis(
			ifBound: { i == $0 ? term : self },
			ifApplication: { Term.application($0.substitute(i, term), $1.substitute(i, term)) },
			ifPi: { Term(.Pi(Box($0.substitute(i, term)), Box($1.substitute(i + 1, term)))) },
			ifProjection: { Term.projection($0.substitute(i, term), $1) },
			ifSigma: { Term(.Sigma(Box($0.substitute(i, term)), Box($1.substitute(i + 1, term)))) },
			otherwise: const(self))
	}


	// MARK: Type-checking

	public func typecheck() -> Either<Error, Value> {
		return typecheck([:], from: 0)
	}

	public func typecheck(context: Context, from i: Int) -> Either<Error, Value> {
		return expression.analysis(
			ifUnitTerm: const(.right(.UnitType)),
			ifUnitType: const(.right(.type)),
			ifType: { .right(.type($0 + 1)) },
			ifBound: { i -> Either<Error, Value> in
				context[.Local(i)].map(Either.right)
					?? Either.left("unexpectedly free bound variable \(i)")
			},
			ifFree: { i -> Either<Error, Value> in
				context[i]
					.map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Value> in
				a.typecheck(context, from: i)
					.flatMap { t in
						t.analysis(
							ifPi: { v, f in b.typecheck(context, against: v, from: i).map(f) },
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
					}
			},
			ifPi: { t, b -> Either<Error, Value> in
				t.typecheck(context, from: i)
					.flatMap { _ in
						let t = t.evaluate()
						return b.substitute(0, .free(.Local(i))).typecheck([ .Local(i): t ] + context, from: i + 1)
							.map { Value.function(t, $0) }
					}
			},
			ifProjection: { a, b -> Either<Error, Value> in
				a.typecheck(context, from: i)
					.flatMap { t in
						t.analysis(
							ifSigma: { v, f in Either.right(b ? f(v) : v) },
							otherwise: const(Either.left("illegal projection of \(a) : \(t) field \(b ? 1 : 0)")))
					}
			},
			ifSigma: { t, b -> Either<Error, Value> in
				t.typecheck(context, from: i)
					.flatMap { t in
						b.substitute(0, .free(.Local(i))).typecheck([ .Local(i): t ] + context, from: i + 1)
							.map { Value.product(t, $0) }
					}
			})
	}

	public func typecheck(context: Context, against: Value, from i: Int) -> Either<Error, Value> {
		return typecheck(context, from: i)
			.flatMap { t in
				let (q, r) = (t.quote, against.quote)
				return (q == r) || (r == .type && q == Value.function(.type, .type).quote)
					? Either.right(t)
					: Either.left("type mismatch: expected (\(toDebugString(self))) : (\(toDebugString(r))), actually (\(toDebugString(self))) : (\(toDebugString(q))) in environment \(context)")
			}
	}


	// MARK: Evaluation

	public func evaluate(_ environment: Environment = Environment()) -> Value {
		return expression.analysis(
			ifUnitTerm: const(.UnitValue),
			ifUnitType: const(.UnitType),
			ifType: Value.type,
			ifBound: { i -> Value in
				environment.local[i]
			},
			ifFree: { i -> Value in
				environment.global[i] ?? .free(i)
			},
			ifApplication: { a, b -> Value in
				a.evaluate(environment).apply(b.evaluate(environment))
			},
			ifPi: { type, body -> Value in
				Value.pi(type.evaluate(environment)) { body.evaluate(environment.byPrepending($0)) }
			},
			ifProjection: { a, b -> Value in
				a.evaluate(environment).project(b)
			},
			ifSigma: { type, body -> Value in
				Value.sigma(type.evaluate(environment)) { body.evaluate(environment.byPrepending($0)) }
			})
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Checkable<String>) -> String {
		return expression.analysis(
			ifUnitTerm: const("()"),
			ifUnitType: const("Unit"),
			ifType: { "Type\($0)" },
			ifBound: { "Bound(\($0))" },
			ifFree: { "Free(\($0))" },
			ifApplication: { "\($0)(\($1))" },
			ifPi: { "Π \($0) . \($1)" },
			ifProjection: { "\($0).\($1 ? 1 : 0)" },
			ifSigma: { "Σ \($0) . \($1)" })
	}


	// MARK: FixpointType

	public var out: Checkable<Term> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		return expression.analysis(
			ifUnitTerm: const(0),
			ifUnitType: const(1),
			ifType: { 2 ^ $0.hashValue },
			ifBound: { 3 ^ $0.hashValue },
			ifFree: { 5 ^ $0.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue },
			ifProjection: { 13 ^ $0.hashValue ^ $1.hashValue },
			ifSigma: { 17 ^ $0.hashValue ^ $1.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Checkable<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.toString(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifUnitTerm: const("()"),
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
			})
	}
}


private func pure<T>(x: T) -> T? {
	return x
}


import Box
import Either
import Prelude
