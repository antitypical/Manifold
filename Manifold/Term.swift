//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: DebugPrintable, FixpointType, Hashable, Printable {
	public init(_ expression: Expression<Term>) {
		self.expression = expression
	}


	// MARK: Constructors

	public static var kind: Term {
		return Term(.Kind)
	}

	public static var type: Term {
		return Term(.Type)
	}


	public static func application(a: Term, _ b: Term) -> Term {
		return Term(.Application(Box(a), Box(b)))
	}


	public static func lambda(type: Term, _ f: Term -> Term) -> Term {
		let body = f(variable(-1))
		let (n, build) = repMax(body)
		return pi(n + 1, type, build(variable(n + 1)))
	}

	public static func pair(type: Term, _ f: Term -> Term) -> Term {
		let body = f(variable(-1))
		let (n, build) = repMax(body)
		return sigma(n + 1, type, build(variable(n + 1)))
	}

	private static func variable(i: Int) -> Term {
		return Term(.Variable(i))
	}

	private static func pi(variable: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Pi(variable, Box(type), Box(body)))
	}

	private static func sigma(variable: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Sigma(variable, Box(type), Box(body)))
	}

	private static func repMax(term: Term) -> (Int, Term -> Term) {
		return term.expression.analysis(
			ifKind: const(-1, const(term)),
			ifType: const(-1, const(term)),
			ifVariable: { i in
				return (i, { i == -1 ? $0 : term })
			},
			ifApplication: { a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(ma, mb), { Term(.Application(Box(builda($0)), Box(buildb($0)))) })
			},
			ifPi: { i, t, b in
				let (mt, buildt) = repMax(t)
				let (mb, buildb) = repMax(b)
				return (max(i, mt, mb), { Term(.Pi(i, Box(buildt($0)), Box(buildb($0)))) })
			},
			ifSigma: { i, a, b in
				let (ma, builda) = repMax(a)
				let (mb, buildb) = repMax(b)
				return (max(i, ma, mb), { Term(.Sigma(i, Box(builda($0)), Box(buildb($0)))) })
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
			ifVariable: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifPi: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			ifSigma: { i, type, body in type.freeVariables.union(body.freeVariables).subtract([ i ]) },
			otherwise: const([]))
	}

	public func typecheck() -> Either<Error, Term> {
		return typecheck([:])
	}

	private func typecheck(environment: [Int: Term]) -> Either<Error, Term> {
		return expression.analysis(
			ifKind: const(Either.right(self)),
			ifType: const(Either.right(self)),
			ifVariable: { i -> Either<Error, Term> in
				environment[i].map(Either.right)
					?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { abs, arg -> Either<Error, Term> in
				(abs.typecheck(environment)
					.flatMap { $0.evaluate(environment) }
					.flatMap { $0.pi != nil ? Either.right($0) : Either.left("cannot apply \(abs) : \($0) to \(arg)") } &&& arg.typecheck(environment)).map(Term.application)
			},
			ifPi: { i, type, body -> Either<Error, Term> in
				(type.typecheck(environment) &&& body.typecheck(environment + [i: type]))
					.map { t, b in Term.lambda(t) { _ in b.substitute(t, forVariable: i) } }
			},
			ifSigma: { i, type, body -> Either<Error, Term> in
				(type.typecheck(environment) &&& body.typecheck(environment + [i: type]))
					.map { t, b in Term.pair(t) { _ in b.substitute(t, forVariable: i) } }
			})
	}


	// MARK: Substitution

	public func substitute(value: Term, forVariable i: Int) -> Term {
		return expression.analysis(
			ifKind: const(self),
			ifType: const(self),
			ifVariable: { $0 == i ? value : Term.variable($0) },
			ifApplication: { Term.application($0.substitute(value, forVariable: i), $1.substitute(value, forVariable: i)) },
			ifPi: { Term.pi($0, $1.substitute(value, forVariable: i), $2.substitute(value, forVariable: i)) },
			ifSigma: { Term.sigma($0, $1.substitute(value, forVariable: i), $2.substitute(value, forVariable: i)) })
	}


	// MARK: Evaluation

	public func evaluate(environment: [Int: Value]) -> Value? {
		return expression.analysis(
			ifKind: const(.Kind),
			ifType: const(.Type),
			ifVariable: { environment[$0] },
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

	public func evaluate() -> Either<Error, Term> {
		return evaluate([:])
	}

	private func evaluate(environment: [Int: Term]) -> Either<Error, Term> {
		return
			typecheck(environment)
			.flatMap { _ in
				expression.analysis(
					ifVariable: {
						environment[$0].map(Either.right)!
					},
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
		return cata(Term.toDebugString)(self)
	}

	private static func toDebugString(expression: Expression<String>) -> String {
		return expression.analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { "\($0)" },
			ifApplication: { "(\($0)) (\($1))" },
			ifPi: { "∏ \($0) : \($1) . \($2)" },
			ifSigma: { "∑ \($0) : \($1) . \($2)" })
	}


	// MARK: FixpointType

	public var out: Expression<Term> {
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
		return para(Term.toString)(self)
	}

	private static let alphabet = "abcdefghijklmnopqrstuvwxyz"

	private static func toString(expression: Expression<(Term, String)>) -> String {
		let alphabetize: Int -> String = { index in Swift.toString(Term.alphabet[advance(Term.alphabet.startIndex, index)]) }
		return expression.analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: alphabetize,
			ifApplication: { "(\($0.1)) (\($1.1))" },
			ifPi: {
				$2.0.freeVariables.contains($0)
					? "∏ \(alphabetize($0)) : \($1.1) . \($2.1)"
					: "(\($1.1)) → \($2.1)"
			},
			ifSigma: {
				$2.0.freeVariables.contains($0)
					? "∑ \(alphabetize($0)) : \($1.1) . \($2.1)"
					: "(\($1.1) ✕ \($2.1))"
			})
	}
}


import Box
import Either
import Prelude
