//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias _Type = Type

public enum Scheme {
	case Type(_Type)
	case Quantified(Int, Constraint, Box<Scheme>)
}


// MARK: - Imports

import Box
