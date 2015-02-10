//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias AssumptionSet = [Expression: Scheme]

public func typeOf(expression: Expression, _ assumptions: AssumptionSet = [:], _ constraints: Multiset<Constraint> = []) -> Either<Error, (AssumptionSet, Multiset<Constraint>)> {
	switch expression {
	case let .Variable:
		return .right([expression: Scheme([], Type(Variable()))], constraints)

	default:
		break
	}
	return .left("unimplemented")
}


// MARK: - Imports

import Either
import Set
