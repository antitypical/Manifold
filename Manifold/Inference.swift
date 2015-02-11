//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias ConstraintSet = Multiset<Constraint>

public func typeOf(expression: Expression) -> Either<Error, (Type, AssumptionSet, ConstraintSet)> {
	return expression.analysis(
		ifVariable: { v in Type(Variable()) |> { type in .right(type, [ v: [ Scheme([], type) ] ], []) } },
		ifAbstraction: const(.left("unimplemented")),
		ifApplication: { e1, e2 in (typeOf(e1) && typeOf(e2)) >>- { e1, e2 in
			let type = Type(Variable())
			let c = Constraint(equality: e1.0, Type(function: e2.0, type))
			return .right(type, e1.1 + e2.1, e1.2 + e2.2 + [ c ]) } })
}


// MARK: - Imports

import Either
import Prelude
import Set
