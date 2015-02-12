//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// Infers the type, assumptions, and constraints for a given `expression`.
public func infer(expression: Expression) -> (Type, assumptions: AssumptionSet, constraints: ConstraintSet) {
	return expression.analysis(
		ifVariable: { v in
			let type = Type(Variable())
			return (type,
				assumptions: [ v: [ type ] ],
				constraints: [])
		},
		ifAbstraction: { x, e in
			let (type, a, c) = infer(e)
			let parameterType = Type(Variable())
			return (parameterType --> type,
				assumptions: a / x,
				constraints: c + lazy(a[x]).map { $0 === parameterType })
		},
		ifApplication: { e1, e2 in
			let (t1, a1, c1) = infer(e1)
			let (t2, a2, c2) = infer(e2)
			let type = Type(Variable())
			return (type,
				assumptions: a1 + a2,
				constraints: c1 + c2 + [ t1 === (t2 --> type) ])
		})
}


// MARK: - Imports

import Either
import Prelude
