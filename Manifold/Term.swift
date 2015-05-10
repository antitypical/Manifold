//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: Expression<Term>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var type: Term {
		return Term(.Type)
	}


	public static func application(a: Term, _ b: Term) -> Term {
		return Term(.Application(Box(a), Box(b)))
	}


	public static func lambda(type: Term, _ f: Term -> Term) -> Term {
		return pi(0, type, f(free(.Quote(0))).quote(1))
	}

	public static func pair(type: Term, _ f: Term -> Term) -> Term {
		return sigma(0, type, f(free(.Quote(0)).quote(1)))
	}

	static func bound(i: Int) -> Term {
		return Term(.Bound(i))
	}

	static func free(name: Name) -> Term {
		return Term(.Free(name))
	}

	private static func pi(bound: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Pi(bound, Box(type), Box(body)))
	}

	private static func sigma(bound: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Sigma(bound, Box(type), Box(body)))
	}

	private func quote(n: Int) -> Term {
		return expression.analysis(
			ifType: const(self),
			ifBound: Term.bound,
			ifFree: { $0.analysis(ifLocal: Term.bound, ifQuote: { Term.bound(n - $0 - 1) }) },
			ifApplication: { Term.application($0.quote(n), $1.quote(n)) },
			ifPi: { Term.pi(n, $1.quote(n), $2.quote(n + 1)) },
			ifSigma: { Term.sigma(n, $1.quote(n), $2.quote(n + 1)) })
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

	public func typecheck(_ environment: [Int: Value] = [:]) -> Either<Error, Value> {
		return expression.analysis(
			ifType: const(Either.right(.Type)),
			ifBound: { i -> Either<Error, Value> in
				environment[i].map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifFree: { i -> Either<Error, Value> in
				environment[i.value].map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Value> in
				a.typecheck(environment)
					.flatMap { t in
						t.analysis(
							ifPi: { v, f in b.typecheck(environment, v).map { _ in b.evaluate().flatMap(f)! } },
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
					}
			},
			ifPi: { i, t, b -> Either<Error, Value> in
				t.typecheck(environment, .Type)
					.flatMap { _ in
						b.typecheck(environment + [ i: t.evaluate(environment)! ])
					}
			},
			ifSigma: { i, t, b -> Either<Error, Value> in
				t.typecheck(environment, .Type)
					.flatMap { _ in
						b.typecheck(environment + [ i: t.evaluate(environment)! ])
					}
			})
	}

	public func typecheck(environment: [Int: Value], _ against: Value) -> Either<Error, Value> {
		return typecheck(environment)
			.flatMap { t in
				let (q, r) = (t.quote, against.quote)
				return q == r
					? Either.right(t)
					: Either.left("type mismatch: got \(q) for \(self) but expected \(r)")
		}
	}


	// MARK: Evaluation

	public func evaluate(_ environment: [Int: Value] = [:]) -> Value? {
		return expression.analysis(
			ifType: const(.Type),
			ifBound: { environment[$0] },
			ifFree: { environment[$0.value] },
			ifApplication: { a, b -> Value? in
				(a.evaluate(environment) &&& b.evaluate(environment))
					.flatMap { $0.apply($1) }
			},
			ifPi: { i, type, body -> Value? in
				type.evaluate(environment)
					.map { type in Value.Pi(Box(type)) { body.evaluate(environment + [ i: $0 ]) } }
			},
			ifSigma: { i, type, body -> Value? in
				type.evaluate(environment)
					.map { type in Value.Sigma(Box(type)) { body.evaluate(environment + [ i: $0 ]) } }
			})
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Expression<String>) -> String {
		return expression.analysis(
			ifType: const("Type"),
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
			ifType: { 2 },
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
			ifBound: alphabetize,
			ifFree: Name.value >>> alphabetize,
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
