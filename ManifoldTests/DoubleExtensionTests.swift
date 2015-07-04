//  Copyright © 2015 Rob Rix. All rights reserved.

final class DoubleExtensionTests: XCTestCase {
	func testInBaseTen() {
		assert(7.log(10) - log10(7), <, epsilon)
	}

	func testInBaseTwo() {
		assert(7.log(2) - log2(7), <, epsilon)
	}
}


let epsilon = 0.000000000000000000000000000000000001


import Assertions
import Darwin
@testable import Manifold
import XCTest
