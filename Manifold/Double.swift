//  Copyright © 2015 Rob Rix. All rights reserved.

extension Double {
	public func log(base: Double) -> Double {
		return Darwin.log(self) / Darwin.log(base)
	}
}


import Darwin
