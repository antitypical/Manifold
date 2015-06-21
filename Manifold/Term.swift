//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: BooleanLiteralConvertible, CustomDebugStringConvertible, FixpointType, Hashable, IntegerLiteralConvertible, CustomStringConvertible {
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


	public static func sum(a: Term, _ b: Term) -> Term {
		return sigma(booleanType, `if`(0, then: a, `else`: b))
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

	public var bound: Int? {
		return expression.analysis(ifBound: Prelude.unit, otherwise: const(nil))
	}

	public var application: (Term, Term)? {
		return expression.analysis(ifApplication: Prelude.unit, otherwise: const(nil))
	}

	public var pi: (Term, Term)? {
		return expression.analysis(ifPi: Prelude.unit, otherwise: const(nil))
	}

	public var sigma: (Term, Term)? {
		return expression.analysis(ifSigma: Prelude.unit, otherwise: const(nil))
	}

	public var boolean: Bool? {
		return expression.analysis(ifBoolean: Prelude.unit, otherwise: const(nil))
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
			ifIf: const(false),
			otherwise: const(true))
	}


	// MARK: Bound variables

	private func mapBoundVariables(transform: (Int, Int) -> Term) -> Term {
		return zeppo { parents, expression in
			expression.analysis(
				ifBound: { transform(parents.count, $0) },
				ifApplication: { Term.application($0, $1) },
				ifPi: { Term.pi($0, $1) },
				ifProjection: { Term.projection($0, $1) },
				ifSigma: { Term.sigma($0, $1) },
				ifIf: { Term.`if`($0, then: $1, `else`: $2) },
				otherwise: const(Term(expression)))
		} (self)
	}


	// MARK: Substitution

	public func substitute(term: Term) -> Term {
		return substitute(0, term.shift(by: 1)).shift(by: -1)
	}

	public func substitute(i: Int, _ term: Term) -> Term {
		return mapBoundVariables { depth, variable in
			variable == i
				? term.shift(0, by: depth)
				: Term.bound(variable)
		}
	}


	// MARK: Shifting

	public func shift(above: Int = 0, by: Int) -> Term {
		return mapBoundVariables { depth, variable in
			Term.bound(variable >= above ? 1 : 0)
		}
	}


	// MARK: Type-checking

	public func typecheck(locals: [Term] = [], _ globals: [Name: Term] = [:]) -> Either<Error, Term> {
		return expression.analysis(
			ifUnit: const(.right(.unitType)),
			ifUnitType: const(.right(.type)),
			ifType: { .right(.type($0 + 1)) },
			ifBound: { i -> Either<Error, Term> in
				Either.right(locals[i])
			},
			ifFree: { i -> Either<Error, Term> in
				globals[i].map(Either.right) ?? Either.left("unexpected free variable \(i)")
			},
			ifApplication: { a, b -> Either<Error, Term> in
				a.typecheck(locals, globals)
					.flatMap { t in
						t.expression.analysis(
							ifPi: { v, f in b.typecheck(locals, globals, against: v).map { f.substitute(0, $0) } },
							otherwise: const(Either.left("illegal application of \(a) : \(t) to \(b)")))
				}
			},
			ifPi: { t, b -> Either<Error, Term> in
				t.typecheck(locals, globals)
					.flatMap { _ in
						b.typecheck([ t.shift(by: 1) ] + locals, globals)
							.map(curry(Term.pi)(t))
					}
			},
			ifProjection: { a, b -> Either<Error, Term> in
				a.typecheck(locals, globals)
					.flatMap { t in
						t.expression.analysis(
							ifSigma: { v, f in Either.right(b ? f.substitute(0, v) : v) },
							otherwise: const(Either.left("illegal projection of \(a) : \(t) field \(b ? 1 : 0)")))
					}
			},
			ifSigma: { a, b -> Either<Error, Term> in
				a.typecheck(locals, globals)
					.flatMap { a in
						let t = a.evaluate()
						return b.typecheck([ t ] + locals, globals)
							.map { Term.sigma(t, $0) }
					}
			},
			ifBooleanType: const(.right(.type)),
			ifBoolean: const(.right(.booleanType)),
			ifIf: { condition, then, `else` -> Either<Error, Term> in
				condition.typecheck(locals, globals, against: .booleanType)
					.flatMap { _ in
						(then.typecheck(locals, globals) &&& `else`.typecheck(locals, globals))
							.map { a, b in
								a == b
									? a
									: Term.sigma(.booleanType, Term.`if`(.bound(0), then: a, `else`: b))
							}
					}
			})
	}

	public func typecheck(locals: [Term], _ globals: [Name: Term], against: Term) -> Either<Error, Term> {
		return typecheck(locals, globals)
			.flatMap { t in
				(t == against) || (against == .type && t == Term.pi(.type, .type))
					? Either.right(t)
					: Either.left("type mismatch: expected (\(String(reflecting: self))) : (\(String(reflecting: against))), actually (\(String(reflecting: self))) : (\(String(reflecting: t))) in local environment \(locals) global environment \(globals)")
			}
	}


	// MARK: Evaluation

	public func evaluate(locals: [Term] = [], _ globals: [Name: Term] = [:]) -> Term {
		return expression.analysis(
			ifUnit: const(self),
			ifUnitType: const(self),
			ifType: const(self),
			ifBound: { i -> Term in
				locals[i]
			},
			ifFree: { i -> Term in
				globals[i] ?? .free(i)
			},
			ifApplication: { a, b -> Term in
				a.evaluate(locals, globals).pi.map { $1.substitute(0, b.evaluate(locals, globals)) }!
			},
			ifPi: const(self),
			ifProjection: { a, b -> Term in
				a.evaluate(locals, globals).sigma.map { b ? $1 : $0 }!
			},
			ifSigma: const(self),
			ifBooleanType: const(self),
			ifBoolean: const(self),
			ifIf: { $0.evaluate(locals, globals).boolean! ? $1.evaluate(locals, globals) : $2.evaluate(locals, globals) })
	}


	// MARK: BooleanLiteralConvertible

	public init(booleanLiteral value: Bool) {
		self = Term.boolean(value)
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
			ifBoolean: { String(reflecting: $0) },
			ifIf: { "if \($0) then \($1) else \($2)" })
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
			ifBoolean: { 23 ^ $0.hashValue },
			ifIf: { 29 ^ $0.hashValue ^ $1.hashValue ^ $2.hashValue })
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self = Term.bound(value)
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
			ifFree: { $0.analysis(ifGlobal: id, ifLocal: alphabetize) },
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
			ifBoolean: { String($0) },
			ifIf: { "if \($0) then \($1) else \($2)" })
	}
}


import Box
import Either
import Prelude
