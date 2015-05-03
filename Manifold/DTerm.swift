//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm {
	public init(_ expression: DExpression<DTerm>) {
		self.expression = expression
	}


	public static func application(a: DTerm, _ b: DTerm) -> DTerm {
		return DTerm(.Application(Box(a), Box(b)))
	}


	public let expression: DExpression<DTerm>
}

public enum DExpression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifConstant: () -> T,
		@noescape ifVariable: Int -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifAbstraction: (Int, Recur, Recur) -> T,
		@noescape ifQuantification: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case .Constant:
			return ifConstant()
		case let .Variable(x):
			return ifVariable(x)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Abstraction(x, a, b):
			return ifAbstraction(x, a.value, b.value)
		case let .Quantification(x, a, b):
			return ifQuantification(x, a.value, b.value)
		}
	}

	public func analysis<T>(
		ifConstant: (() -> T)? = nil,
		ifVariable: (Int -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifAbstraction: ((Int, Recur, Recur) -> T)? = nil,
		ifQuantification: ((Int, Recur, Recur) -> T)? = nil,
		otherwise: () -> T) -> T {
		return analysis(
			ifConstant: { ifConstant?() ?? otherwise() },
			ifVariable: { ifVariable?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifAbstraction: { ifAbstraction?($0) ?? otherwise() },
			ifQuantification: { ifQuantification?($0) ?? otherwise() })
	}


	// MARK: Cases

	case Constant
	case Variable(Int)
	case Application(Box<Recur>, Box<Recur>)
	case Abstraction(Int, Box<Recur>, Box<Recur>)
	case Quantification(Int, Box<Recur>, Box<Recur>)
}


import Box
