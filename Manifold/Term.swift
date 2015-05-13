//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: Expression<Term>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var type: Term {
		return Term(.Type)
	}


	public static func constant(value: Any, _ type: Term) -> Term {
		return Term(.Constant(value, Box(type)))
	}


	public static func application(a: Term, _ b: Term) -> Term {
		return Term(.Application(Box(a), Box(b)))
	}


	static func bound(i: Int) -> Term {
		return Term(.Bound(i))
	}

	static func free(name: Name) -> Term {
		return Term(.Free(name))
	}


	// MARK: Destructors

	public var isType: Bool {
		return expression.analysis(
			ifType: const(true),
			otherwise: const(false))
	}

	public var constant: (Any, Term)? {
		return expression.analysis(
			ifConstant: unit,
			otherwise: const(nil))
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

	public var pi: (Int, Term, Term)? {
		return expression.analysis(
			ifPi: unit,
			otherwise: const(nil))
	}

	public var sigma: (Int, Term, Term)? {
		return expression.analysis(
			ifSigma: unit,
			otherwise: const(nil))
	}

	public let expression: Expression<Term>


	// MARK: Type-checking

	public var freeVariables: Set<Int> {
		return expression.analysis(
			ifBound: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifPi: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			ifSigma: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			otherwise: const([]))
	}

	public func typecheck(_ environment: Environment = [:]) -> Either<Error, Value> {
		return expression.analysis(
			ifType: const(Either.right(.Type)),
			ifConstant: { $1.typecheck(environment) },
			ifBound: { i -> Either<Error, Value> in
				environment[.Local(i)].map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifFree: { i -> Either<Error, Value> in
				environment[i].map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Value> in
				a.typecheck(environment)
					.flatMap { t in
						t.analysis(
							ifPi: { v, f in b.typecheck(environment, v).flatMap(f) },
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
					}
			},
			ifPi: { i, t, b -> Either<Error, Value> in
				t.typecheck(environment, .Type)
					.map { t in Value.Pi(Box(t)) { _ in b.typecheck(environment + [ .Local(i): t ]) } }
			},
			ifSigma: { i, t, b -> Either<Error, Value> in
				t.typecheck(environment, .Type)
					.map { t in Value.Sigma(Box(t)) { _ in b.typecheck(environment + [ .Local(i): t ]) } }
			})
	}

	public func typecheck(environment: Environment, _ against: Value) -> Either<Error, Value> {
		return typecheck(environment)
			.flatMap { t in
				let (q, r) = (t.quote, against.quote)
				return q == r
					? Either.right(t)
					: Either.left("type mismatch: expected (\(toDebugString(self))) : (\(toDebugString(r))), actually (\(toDebugString(self))) : (\(toDebugString(q))) in environment \(environment)")
			}
	}


	// MARK: Evaluation

	public func evaluate(_ environment: Environment = [:]) -> Either<Error, Value> {
		return expression.analysis(
			ifType: const(Either.right(.Type)),
			ifConstant: { $1.evaluate(environment).map(curry(Value.constant)($0)) },
			ifBound: { i -> Either<Error, Value> in
				environment[.Local(i)].map(Either.right) ?? Either.left("unexpected free variable \(i)")
			},
			ifFree: { i -> Either<Error, Value> in
				environment[i].map(Either.right) ?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Value> in
				(a.evaluate(environment) &&& b.evaluate(environment))
					.flatMap { $0.apply($1) }
			},
			ifPi: { i, type, body -> Either<Error, Value> in
				type.evaluate(environment)
					.map { type in Value.Pi(Box(type)) { body.evaluate(environment + [ .Local(i): $0 ]) } }
			},
			ifSigma: { i, type, body -> Either<Error, Value> in
				type.evaluate(environment)
					.map { type in Value.Sigma(Box(type)) { body.evaluate(environment + [ .Local(i): $0 ]) } }
			})
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Expression<String>) -> String {
		return expression.analysis(
			ifType: const("Type"),
			ifConstant: { "Constant(\(Swift.toDebugString($0)) : \($1))" },
			ifBound: { "Bound(\($0))" },
			ifFree: { "Free(\($0))" },
			ifApplication: { "(\($0)) (\($1))" },
			ifPi: { "Π \($0) : \($1) . \($2)" },
			ifSigma: { "Σ \($0) : \($1) . \($2)" })
	}


	// MARK: FixpointType

	public var out: Expression<Term> {
		return expression
	}


	// MARK: Hashable

	public var hashValue: Int {
		return expression.analysis(
			ifType: { 1 },
			ifConstant: { 2 ^ $1.hashValue },
			ifBound: { 3 ^ $0.hashValue },
			ifFree: { 5 ^ $0.hashValue },
			ifApplication: { 7 ^ $0.hashValue ^ $1.hashValue },
			ifPi: { 11 ^ $0.hashValue ^ $1.hashValue ^ $2.hashValue },
			ifSigma: { 13 ^ $0.hashValue ^ $1.hashValue ^ $2.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Expression<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.toString(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifType: const("Type"),
			ifConstant: { "(\($0)) : \($1)" },
			ifBound: alphabetize,
			ifFree: { $0.analysis(ifGlobal: id, ifLocal: alphabetize, ifQuote: alphabetize) },
			ifApplication: { "(\($0.1)) (\($1.1))" },
			ifPi: {
				$2.0.freeVariables.contains($0)
					? "Π \(alphabetize($0)) : \($1.1) . \($2.1)"
					: "(\($1.1)) → \($2.1)"
			},
			ifSigma: {
				$2.0.freeVariables.contains($0)
					? "Σ \(alphabetize($0)) : \($1.1) . \($2.1)"
					: "(\($1.1) ✕ \($2.1))"
			})
	}
}


import Box
import Either
import Prelude
