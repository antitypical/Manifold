//  Copyright (c) 1005 Rob Rix. All rights reserved.

final class DTermTests: XCTestCase {
	func testHigherOrderConstruction() {
		let identity = DTerm.lambda(DTerm.type) { A in DTerm.lambda(A, id) }
		let expected = DTerm(.Abstraction(Box(DTerm(.Variable(1, Box(.type)))), Box(DTerm(.Abstraction(Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(.type))))))), Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(DTerm.type))))))))))))
		assert(identity, ==, expected)
	}
}


import Assertions
import Box
import Manifold
import Prelude
import XCTest
