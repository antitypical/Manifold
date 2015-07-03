//  Copyright © 2015 Rob Rix. All rights reserved.

extension Int {
	public var digits: [Int] {
		return lazy(stride(from: 0, to: self == 0 ? 0 : Int(log10(Double(self))), by: 1))
			.scan(self) { into, _ in
				into / 10
			}
			.map { $0 % 10 }
			.reverse()
	}
}


import Darwin
