//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression: Hashable {
	public init(variable: Int) {
		self = Variable(variable)
	}

	public init(apply e1: Expression, to e2: Expression) {
		self = Application(Box(e1), Box(e2))
	}

	public init(abstract x: Int, body: Expression) {
		self = Abstraction(x, Box(body))
	}


	case Variable(Int)
	case Abstraction(Int, Box<Expression>)
	case Application(Box<Expression>, Box<Expression>)


	public func analysis<T>(#ifVariable: Int -> T, ifAbstraction: (Int, Expression) -> T, ifApplication: (Expression, Expression) -> T) -> T {
		switch self {
		case let Variable(v):
			return ifVariable(v)

		case let Abstraction(x, e):
			return ifAbstraction(x, e.value)

		case let Application(e1, e2):
			return ifApplication(e1.value, e2.value)
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(
			ifVariable: { $0.hashValue },
			ifAbstraction: { $0.hashValue ^ $1.hashValue },
			ifApplication: { $0.hashValue ^ $1.hashValue })
	}
}

/// Equality up to renaming.
public func == (left: Expression, right: Expression) -> Bool {
	switch (left, right) {
	case let (.Variable, .Variable):
		return true

	case let (.Abstraction(x, e1), .Abstraction(y, e2)):
		return e1.value == e2.value

	case let (.Application(x1, y1), .Application(x2, y2)):
		return x1.value == x2.value && y1.value == y2.value

	default:
		return false
	}
}


// MARK: - Imports

import Box
