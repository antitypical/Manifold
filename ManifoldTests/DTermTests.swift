//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class DTermTests: XCTestCase {
	func testHigherOrderConstruction() {
		let expected = DTerm(.Pi(Box(DTerm(.Variable(1, Box(.type)))), Box(DTerm(.Pi(Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(.type))))))), Box(DTerm(.Variable(0, Box(DTerm(.Variable(1, Box(.type))))))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right, ==, .lambda(.type, const(.lambda(.type, const(.type)))))
	}

	func testFunctionTypesArePrintedWithAnArrow() {
		assert(identity.typecheck().right?.description, ==, "(Type) → (Type) → Type")
	}

	func testProductTypesArePrintedWithAnX() {
		assert(DTerm.pair(.type, const(.type)).typecheck().right?.description, ==, "(Type ✕ Type)")
	}

	func testEvaluation() {
		let value = identity.typecheck().flatMap { DTerm.application(DTerm.application(identity, $0), identity).evaluate() }
		assert(value.right, ==, identity)
		assert(value.left, ==, nil)
	}
}


private let identity = DTerm.lambda(.type) { A in .lambda(A, id) }


import Assertions
import Box
import Manifold
import Prelude
import XCTest
