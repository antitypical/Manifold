//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression {
	case Value(Manifold.Value)
	case Application(Box<Expression>, Box<Expression>)
}


// MARK: - Imports

import Box
