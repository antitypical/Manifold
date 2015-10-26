//  Copyright © 2015 Rob Rix. All rights reserved.

extension Int {
	public func digits(base: Int) -> [Int] {
		return (0..<(self <= 0 ? 0 : Int(Double(self).log(Double(base)))))
			.reduce([self]) { into, _ in into + [ into.last! / base ] }
			.map { $0 % base }
			.reverse()
	}
}
