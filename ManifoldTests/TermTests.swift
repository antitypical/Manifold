//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testHigherOrderConstruction() {
		let expected = Term(.Pi(1, Box(.type), Box(Term(.Pi(0, Box(Term(.Variable(1))), Box(Term(.Variable(0))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right, ==, .lambda(.type, const(.lambda(.type, const(.type)))))
	}

	func testFunctionTypesArePrintedWithAnArrow() {
		assert(identity.typecheck().right?.description, ==, "(Type) → (Type) → Type")
	}

	func testProductTypesArePrintedWithAnX() {
		assert(Term.pair(.type, const(.type)).typecheck().right?.description, ==, "(Type ✕ Type)")
	}

	func testEvaluation() {
		let value = identity.typecheck().flatMap { Term.application(Term.application(identity, $0), identity).evaluate() }
		assert(value.right, ==, identity)
		assert(value.left, ==, nil)
	}
}


private let identity = Term.lambda(.type) { A in .lambda(A, id) }


import Assertions
import Box
import Manifold
import Prelude
import XCTest
