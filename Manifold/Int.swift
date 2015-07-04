//  Copyright © 2015 Rob Rix. All rights reserved.

extension Int {
	public func digits(base: Int) -> [Int] {
		return lazy(stride(from: 0, to: self == 0 ? 0 : Int(Double(self).log(Double(base))), by: 1))
			.scan(self) { into, _ in
				into / base
			}
			.map { $0 % base }
			.reverse()
	}

	public var digits: [Int] {
		return digits(10)
	}
}
