//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Constraint {
	case And(Box<Constraint>, Box<Constraint>)
	case Existential(Int, Box<Constraint>)
	case Congruence(Type, Type)
}


// MARK: - Imports

import Box
