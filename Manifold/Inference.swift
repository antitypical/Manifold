//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias AssumptionSet = [Expression: Scheme]

public func typeOf(expression: Expression, _ assumptions: AssumptionSet = [:], _ constraints: Multiset<Constraint> = []) -> Either<Error, Type> {
	switch expression {
	case let .Value(value):
		switch value {
		case .Variable:
			return .right(Type(Variable()))

		default:
			break
		}


	default:
		break
	}
	return .left("unimplemented")
}


// MARK: - Imports

import Either
import Set
