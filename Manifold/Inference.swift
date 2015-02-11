//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias ConstraintSet = Multiset<Constraint>

public func typeOf(expression: Expression) -> Either<Error, (Type, assumptions: AssumptionSet, constraints: ConstraintSet)> {
	return expression.analysis(
		ifVariable: { v in
			let type = Type(Variable())
			return .right(type,
				assumptions: [ v: [ type ] ],
				constraints: [])
		},
		ifAbstraction: { x, e in typeOf(e) >>- { e in
			let parameterType = Type(Variable())
			return .right(parameterType --> e.0,
				assumptions: e.assumptions / x,
				constraints: e.constraints + lazy(e.assumptions[x]).map { $0 === parameterType })
		}},
		ifApplication: { e1, e2 in (typeOf(e1) && typeOf(e2)) >>- { e1, e2 in
			let type = Type(Variable())
			let constraints = [ e1.0 === (e2.0 --> type) ]
			return .right(type,
				assumptions: e1.assumptions + e2.assumptions,
				constraints: e1.constraints + e2.constraints + constraints)
		}})
}


// MARK: - Imports

import Either
import Prelude
import Set
