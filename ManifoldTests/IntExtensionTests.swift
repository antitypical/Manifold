//  Copyright © 2015 Rob Rix. All rights reserved.

final class IntExtensionTests: XCTestCase {
	func testThereIsOneDigitInZero() {
		assert(0.digits, ==, [0])
	}

	func testThereIsOneDigitInNine() {
		assert(9.digits, ==, [9])
	}

	func testThereAreTwoDigitsInTen() {
		assert(10.digits, ==, [1, 0])
	}

	func testThereAreTwoDigitsInNinetyNine() {
		assert(99.digits, ==, [9, 9])
	}

	func testThereAreThreeDigitsInOneHundredAndTwentyThree() {
		assert(123.digits, ==, [1, 2, 3])
	}
}


import Assertions
@testable import Manifold
import XCTest
