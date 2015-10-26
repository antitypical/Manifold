//  Copyright © 2015 Rob Rix. All rights reserved.

extension Int {
	public func digits(base: Int) -> [Int] {
		return Repeat(count: self <= 0 ? 0 : Int(log(Double(self)) / log(Double(base))), repeatedValue: 0)
			.reduce(([self % base], self)) { into, _ -> ([Int], Int) in ([ (into.1 / base) % base ] + into.0, into.1 / base) }.0
	}
}


import Darwin
