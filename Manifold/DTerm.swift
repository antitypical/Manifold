//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm {
	public init(_ expression: DExpression<DTerm>) {
		self.expression = expression
	}


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
		let (type, body) = f(variable(-1, DTerm.kind))
		let (n, build) = lambdaHelper(DTerm(.Abstraction(-1, Box(type), Box(body))))
		return build(n + 1, type)
	}

	private static func variable(i: Int, _ type: DTerm) -> DTerm {
		return DTerm(.Variable(i, Box(type)))
	}

	private static func abstraction(i: Int, _ type: DTerm, _ body: DTerm) -> DTerm {
		return DTerm(.Abstraction(i, Box(type), Box(body)))
	}
	
	private static func lambdaHelper(t: DTerm) -> (Int, (Int, DTerm) -> DTerm) {
		return t.expression.analysis(
			ifKind: const(0, const(t)),
			ifType: const(0, const(t)),
			ifVariable: { i, _ in (0, { i == -1 ? self.variable($0, $1) : t }) },
			ifApplication: { a, b in
				let (ma, builda) = lambdaHelper(a)
				let (mb, buildb) = lambdaHelper(b)
				return (max(ma, mb), { self.application(builda($0), buildb($0)) })
			},
			ifAbstraction: { i, t, b in
				let (mt, buildt) = lambdaHelper(t)
				let (mb, buildb) = lambdaHelper(b)
				return (i, { self.abstraction(i == -1 ? $0 : i, buildt($0, $1), buildb($0, $1)) })
			})
	}


	public var freeVariables: Set<Int> {
		return expression.analysis(
			ifVariable: { [ $0.0 ] },
			ifApplication: { $0.freeVariables.union($1.freeVariables) },
			ifAbstraction: { $2.freeVariables.subtract([ $0 ]).union($1.freeVariables) },
			otherwise: const([]))
	}

	public var type: DTerm {
		return expression.analysis(
			ifKind: { self },
			ifType: { DTerm.kind },
			ifVariable: { $1 },
			ifApplication: { DTerm.application($0.type, $1.type) },
			ifAbstraction: { _, type, body in DTerm.lambda { x in (type, DTerm.application(x, body)) } })
	}


	public let expression: DExpression<DTerm>
}

public enum DExpression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifKind: () -> T,
		@noescape ifType: () -> T,
		@noescape ifVariable: (Int, Recur) -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifAbstraction: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case .Kind:
			return ifKind()
		case .Type:
			return ifType()
		case let .Variable(x, type):
			return ifVariable(x, type.value)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Abstraction(x, a, b):
			return ifAbstraction(x, a.value, b.value)
		}
	}

	public func analysis<T>(
		ifKind: (() -> T)? = nil,
		ifType: (() -> T)? = nil,
		ifVariable: ((Int, Recur) -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifAbstraction: ((Int, Recur, Recur) -> T)? = nil,
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
	case Abstraction(Int, Box<Recur>, Box<Recur>)
}


import Box
import Prelude
