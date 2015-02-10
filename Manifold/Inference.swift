//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias AssumptionSet = [(Expression, Scheme)]

public typealias ConstraintSet = Multiset<Constraint>

public func typeOf(expression: Expression, _ assumptions: AssumptionSet = [], _ constraints: ConstraintSet = []) -> Either<Error, (AssumptionSet, ConstraintSet)> {

	return expression.analysis(
		const(.right([ (expression, Scheme([], Type(Variable()))) ], constraints)),
		const(.left("unimplemented")),
		const(.left("unimplemented"))
	)
}


// MARK: - Imports

import Either
import Prelude
import Set
