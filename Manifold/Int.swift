//  Copyright © 2015 Rob Rix. All rights reserved.

extension Int {
	public func digits(base: Int) -> [Int] {
		return Array(count: self <= 0 ? 0 : Int(log(Double(self)) / log(Double(base))), repeatedValue: 0)
			.reduce([self]) { into, _ in into + [ into.last! / base ] }
			.map { $0 % base }
			.reverse()
	}
}


import Darwin
