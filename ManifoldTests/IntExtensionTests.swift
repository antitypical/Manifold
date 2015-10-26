//  Copyright © 2015 Rob Rix. All rights reserved.

final class IntExtensionTests: XCTestCase {
	func testThereIsOneDigitInZero() {
		assert(0.digits(10), ==, [0])
	}

	func testThereIsOneDigitInNine() {
		assert(9.digits(10), ==, [9])
	}

	func testThereAreTwoDigitsInTen() {
		assert(10.digits(10), ==, [1, 0])
	}

	func testThereAreTwoDigitsInNinetyNine() {
		assert(99.digits(10), ==, [9, 9])
	}

	func testThereAreThreeDigitsInOneHundredAndTwentyThree() {
		assert(123.digits(10), ==, [1, 2, 3])
	}

	func testBinaryDigits() {
		assert(4.digits(2), ==, [ 1, 0, 0 ])
		assert(7.digits(2), ==, [ 1, 1, 1 ])
	}

	func testHexDigits() {
		assert(0.digits(16), ==, [ 0 ])
		assert(255.digits(16), ==, [ 15, 15 ])
		assert(65535.digits(16), ==, [ 15, 15, 15, 15 ])
	}
}


import Assertions
@testable import Manifold
import XCTest
