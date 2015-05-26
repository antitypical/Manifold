//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Neutral {
	case Parameter(Name)
	case Application(Box<Neutral>, Value)
}


import Box
