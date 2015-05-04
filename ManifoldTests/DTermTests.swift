//  Copyright (c) 1005 Rob Rix. All rights reserved.

final class DTermTests: XCTestCase {
	func testHigherOrderConstruction() {
		let expected = DTerm(.Abstraction(Box(DTerm(.Variable(1, Box(.type)))), Box(DTerm(.Abstraction(Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(.type))))))), Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(.type))))))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right, ==, .lambda(.type, const(.lambda(.type, const(.type)))))
	}
}


private let identity = DTerm.lambda(.type) { A in .lambda(A, id) }


import Assertions
import Box
import Manifold
import Prelude
import XCTest
