//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias ConstraintSet = Multiset<Constraint>

public func typeOf(expression: Expression) -> Either<Error, (AssumptionSet, ConstraintSet)> {
	return expression.analysis(
		{ .right([ $0: [ Scheme([], Type(Variable())) ] ], []) },
		const(.left("unimplemented")),
		{ (typeOf($0) && typeOf($1)) >>- { .right($0.0 + $1.0, $0.1 + $1.1) } })
}


// MARK: - Imports

import Either
import Prelude
import Set
