//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class AlgebraTests: XCTestCase {
	func testCountingUnit() {
		XCTAssertEqual(cata(count)(Term(.Unit)), 1)
	}

	func testCountingBool() {
		XCTAssertEqual(cata(count)(Term(.Sum(Box(Term(.Unit)), Box(Term(.Unit))))), 3)
	}
}


public func count(c: Constructor<Int>) -> Int {
	return 1 + c.analysis(
		ifUnit: 0,
		ifFunction: +,
		ifSum: +)
}


// MARK: - Imports

import Box
import Manifold
import XCTest
