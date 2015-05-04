//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm: FixpointType, Hashable, Printable {
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
		let (n, build) = lambdaHelper(DTerm.abstraction(lambdaPlaceholder, body))
		return build(Box(variable(n + 1, type)))
	}

	private static func variable(i: Int, _ type: DTerm) -> DTerm {
		return DTerm(.Variable(i, Box(type)))
	}

	private static func abstraction(variable: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Abstraction(Box(variable), Box(body)))
	}

	private static var lambdaPlaceholder = variable(-1, DTerm.kind)

	private static func lambdaHelper(term: DTerm) -> (Int, Box<DTerm> -> DTerm) {
		return term.expression.analysis(
			ifKind: const(-3, const(term)),
			ifType: const(-2, const(term)),
			ifVariable: { i, t in
				let (mt, buildt) = lambdaHelper(t)
				return (max(i, mt), { DTerm(.Variable(i, t == DTerm.lambdaPlaceholder ? $0 : Box(buildt($0)))) })
			},
			ifApplication: { a, b in
				let (ma, builda) = lambdaHelper(a)
				let (mb, buildb) = lambdaHelper(b)
				return (max(ma, mb), { DTerm(.Application(a == DTerm.lambdaPlaceholder ? $0 : Box(builda($0)), b == DTerm.lambdaPlaceholder ? $0 : Box(buildb($0)))) })
			},
			ifAbstraction: { t, b in
				let (mt, buildt) = lambdaHelper(t)
				let (mb, buildb) = lambdaHelper(b)
				return (max(mt, mb), { DTerm(.Abstraction(t == DTerm.lambdaPlaceholder ? $0 : Box(buildt($0)), b == DTerm.lambdaPlaceholder ? $0 : Box(buildb($0)))) })
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

	public var abstraction: (DTerm, DTerm)? {
		return expression.analysis(
			ifAbstraction: unit,
			otherwise: const(nil))
	}

	public let expression: DExpression<DTerm>


	// MARK: Type-checking

	public var freeVariables: Set<Int> {
		return expression.analysis(
			ifVariable: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifAbstraction: { $0.freeVariables.subtract([ $0.variable!.0 ]).union($1.freeVariables) },
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
			ifApplication: {
				($0.typecheck(environment).flatMap { $0.abstraction != nil ? Either.right($0) : Either.left("cannot apply to instances of type \($0)") } &&& $1.typecheck(environment)).map(DTerm.application)
			},
			ifAbstraction: { type, body in
				type.variable.map { i, t in
					body.typecheck(environment.union([ Binding(i, t) ]))
						.map { b in DTerm.lambda(t) { x in b.substitute(t, forVariable: type) } }
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
			ifAbstraction: { DTerm.abstraction($0.substitute(value, forVariable: variable), $1.substitute(value, forVariable: variable)) })
	}


	// MARK: Evaluation

	public func evaluate(value: DTerm) -> Either<Error, DTerm> {
		return .left("unimplemented")
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
			ifAbstraction: { 11 ^ $0.hashValue ^ $1.hashValue })
	}


	// MARK: Printable

	public var description: String {
		return expression.analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { "\($0) : \($1)" },
			ifApplication: { "(\($0)) (\($1))" },
			ifAbstraction: { "λ \($0) . \($1)" })
	}
}

public enum DExpression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifVariable: (Int, Recur) -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifAbstraction: (Recur, Recur) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Variable(x, type):
			return ifVariable(x, type.value)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Abstraction(a, b):
			return ifAbstraction(a.value, b.value)
		}
	}

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifVariable: ((Int, Recur) -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifAbstraction: ((Recur, Recur) -> T)? = nil,
		otherwise: () -> T) -> T {
		return analysis(
			ifKind: { ifKind?() ?? otherwise() },
			ifType: { ifType?() ?? otherwise() },
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifAbstraction: { ifAbstraction?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> DExpression<T> {
		return analysis(
			ifKind: { .Kind },
			ifType: { .Type },
			ifVariable: { .Variable($0, Box(transform($1))) },
			ifApplication: { .Application(Box(transform($0)), Box(transform($1))) },
			ifAbstraction: { .Abstraction(Box(transform($0)), Box(transform($1))) })
	}


	// MARK: Cases

	case Kind
	case Type
	case Variable(Int, Box<Recur>)
	case Application(Box<Recur>, Box<Recur>)
	case Abstraction(Box<Recur>, Box<Recur>)
}


private func == (left: DTerm.Binding, right: DTerm.Binding) -> Bool {
	return left.variable == right.variable && left.value == right.value
}


import Box
import Either
import Prelude
import Set
