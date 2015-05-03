//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm: Equatable, Printable {
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


	public static func lambda(f: DTerm -> (DTerm, DTerm)) -> DTerm {
		let (type, body) = f(lambdaPlaceholder)
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

	public var variable: Int? {
		return expression.analysis(
			ifVariable: { $0.0 },
			otherwise: const(nil))
	}


	public var freeVariables: Set<Int> {
		return expression.analysis(
			ifVariable: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifAbstraction: { $0.freeVariables.subtract([ $0.variable! ]).union($1.freeVariables) },
			otherwise: const([]))
	}

	public var type: DTerm {
		return expression.analysis(
			ifKind: { self },
			ifType: { DTerm.kind },
			ifVariable: { $1 },
			ifApplication: { DTerm.application($0.type, $1.type) },
			ifAbstraction: { type, body in DTerm.lambda { x in (type, DTerm.application(x, body)) } })
	}


	public let expression: DExpression<DTerm>


	// MARK: Printable

	public var description: String {
		return expression.analysis(
			ifKind: const("Kind"),
			ifType: const("Type"),
			ifVariable: { "\($0) : \($1)" },
			ifApplication: { "(\($0) \($1))" },
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


	// MARK: Cases

	case Kind
	case Type
	case Variable(Int, Box<Recur>)
	case Application(Box<Recur>, Box<Recur>)
	case Abstraction(Box<Recur>, Box<Recur>)
}


import Box
import Prelude
