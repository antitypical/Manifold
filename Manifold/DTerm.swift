//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DTerm {
	public init(_ expression: DExpression<DTerm>) {
		self.expression = expression
	}


	public let expression: DExpression<DTerm>
}

public enum DExpression<Recur> {

	// MARK: Cases

	case Constant
	case Variable(Int)
	case Application(Box<Recur>, Box<Recur>)
	case Abstraction(Int, Box<Recur>, Box<Recur>)
	case Quantification(Int, Box<Recur>, Box<Recur>)
}


import Box
