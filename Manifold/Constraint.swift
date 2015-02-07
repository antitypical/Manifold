//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint {
	public init(_ c1: Constraint, and c2: Constraint) {
		self = And(Box(c1), Box(c2))
	}

	public init(exists: Variable, inConstraint: Constraint) {
		self = Existential(exists, Box(inConstraint))
	}

	public init(_ t1: Type, equals t2: Type) {
		self = Congruence(t1, t2)
	}


	case And(Box<Constraint>, Box<Constraint>)
	case Existential(Variable, Box<Constraint>)
	case Congruence(Type, Type)
}


// MARK: - Imports

import Box
