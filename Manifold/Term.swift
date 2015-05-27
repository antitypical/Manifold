//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: Checkable<Term>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var type: Term {
		return Term(.Type)
	}


	public static func application(a: Term, _ b: Term) -> Term {
		return Term(.Application(Box(a), Box(b)))
	}


	static func bound(i: Int) -> Term {
		return Term(.Bound(i))
	}

	public static func free(name: Name) -> Term {
		return Term(.Free(name))
	}


	// MARK: Destructors

	public var isType: Bool {
		return expression.analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var bound: Int? {
		return expression.analysis(
			ifBound: unit,
			otherwise: const(nil))
	}

	public var application: (Term, Term)? {
		return expression.analysis(
			ifApplication: unit,
			otherwise: const(nil))
	}

	public var pi: (Term, Term)? {
		return expression.analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (Term, Term)? {
		return expression.analysis(
			ifSigma: unit,
			otherwise: const(nil))
	}

	public let expression: Checkable<Term>


	// MARK: Type-checking

	public func typecheck() -> Either<Error, Value> {
		return typecheck([], from: 0)
	}

	public func typecheck(context: Context, from i: Int) -> Either<Error, Value> {
		return expression.analysis(
			ifType: const(Either.right(.Type)),
			ifBound: { i -> Either<Error, Value> in
				lookup(context, .Local(i)).map(Either.right)
					?? Either.left("unexpectedly free bound variable \(i)")
			},
			ifFree: { i -> Either<Error, Value> in
				lookup(context, i)
					.map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Value> in
				a.typecheck(context, from: i)
					.flatMap { t in
						t.analysis(
							ifPi: { v, f in b.typecheck(context, against: v, from: i).flatMap(f) },
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
					}
			},
			ifPi: { t, b -> Either<Error, Value> in
				t.typecheck(context, against: .Type, from: i)
					.map { t in Value.Pi(Box(t)) { _ in b.typecheck([ (.Local(i), t) ] + context, from: i) } }
			},
			ifSigma: { t, b -> Either<Error, Value> in
				t.typecheck(context, against: .Type, from: i)
					.map { t in Value.Sigma(Box(t)) { _ in b.typecheck([ (.Local(i), t) ] + context, from: i) } }
			})
	}

	public func typecheck(context: Context, against: Value, from i: Int) -> Either<Error, Value> {
		return typecheck(context, from: i)
			.flatMap { t in
				let (q, r) = (t.quote, against.quote)
				return (q == r) || (r == .type && q == Value.function(.Type, .Type).quote)
					? Either.right(t)
					: Either.left("type mismatch: expected (\(toDebugString(self))) : (\(toDebugString(r))), actually (\(toDebugString(self))) : (\(toDebugString(q))) in environment \(context)")
			}
	}


	// MARK: Evaluation

	public func evaluate(_ environment: Environment = []) -> Either<Error, Value> {
		return expression.analysis(
			ifType: const(Either.right(.Type)),
			ifBound: { i -> Either<Error, Value> in
				.right(environment[i])
			},
			ifFree: { i -> Either<Error, Value> in
				.right(.parameter(i))
			},
			ifApplication: { a, b -> Either<Error, Value> in
				(a.evaluate(environment) &&& b.evaluate(environment))
					.flatMap { $0.apply($1) }
			},
			ifPi: { type, body -> Either<Error, Value> in
				type.evaluate(environment)
					.map { type in Value.Pi(Box(type)) { body.evaluate([ $0 ] + environment) } }
			},
			ifSigma: { type, body -> Either<Error, Value> in
				type.evaluate(environment)
					.map { type in Value.Sigma(Box(type)) { body.evaluate([ $0 ] + environment) } }
			})
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Checkable<String>) -> String {
		return expression.analysis(
			ifType: const("Type"),
			ifBound: { "Bound(\($0))" },
			ifFree: { "Free(\($0))" },
			ifApplication: { "\($0)(\($1))" },
			ifPi: { "Π \($0) . \($1)" },
			ifSigma: { "Σ \($0) . \($1)" })
	}


	// MARK: FixpointType

	public var out: Checkable<Term> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		return expression.analysis(
			ifType: { 2 },
			ifBound: { 3 ^ $0.hashValue },
			ifFree: { 5 ^ $0.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue },
			ifSigma: { 13 ^ $0.hashValue ^ $1.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Checkable<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.toString(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifType: const("Type"),
			ifBound: alphabetize,
			ifFree: { $0.analysis(ifGlobal: id, ifLocal: alphabetize, ifQuote: alphabetize) },
			ifApplication: { "\($0.1)(\($1.1))" },
			ifPi: {
				"Π : \($0.1) . \($1.1)"
			},
			ifSigma: {
				"Σ \($0.1) . \($1.1)"
			})
	}
}


import Box
import Either
import Prelude
