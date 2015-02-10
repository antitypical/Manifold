//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias AssumptionSet = [Expression: Scheme]

public func typeOf(expression: Expression, _ assumptions: AssumptionSet = [:], _ constraints: Multiset<Constraint> = []) -> Either<Error, (AssumptionSet, Multiset<Constraint>)> {

	return expression.analysis(
		const(.right([expression: Scheme([], Type(Variable()))], constraints)),
		const(.left("unimplemented")),
		const(.left("unimplemented"))
	)
}


// MARK: - Imports

import Either
import Prelude
import Set
