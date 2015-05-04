//  Copyright (c) 2015 Rob Rix. All rights reserved.

extension DTerm {
	public static func function(t1: DTerm, _ t2: DTerm) -> DTerm {
		return DTerm(.Abstraction(Box(t1), Box(t2)))
	}
}


import Box
