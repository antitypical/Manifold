//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias ConstraintSet = Multiset<Constraint>

/// Infers the type, assumptions, and constraints for a given `expression`.
public func infer(expression: Expression) -> Either<Error, (Type, assumptions: AssumptionSet, constraints: ConstraintSet)> {
	return expression.analysis(
		ifVariable: { v in
			let type = Type(Variable())
			return .right(type,
				assumptions: [ v: [ type ] ],
				constraints: [])
		},
		ifAbstraction: { x, e in infer(e) >>- { e in
			let parameterType = Type(Variable())
			return .right(parameterType --> e.0,
				assumptions: e.assumptions / x,
				constraints: e.constraints + lazy(e.assumptions[x]).map { $0 === parameterType })
		}},
		ifApplication: { e1, e2 in (infer(e1) && infer(e2)) >>- { e1, e2 in
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
