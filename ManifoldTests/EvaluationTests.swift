//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term.unitTerm.evaluate(), ==, Term.unitTerm)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term.unitType.evaluate(), ==, Term.unitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate(), ==, Term.type)
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(Term.application(identity, Term.unitTerm).evaluate(), ==, Term.unitTerm)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		let identity = Term.pi(.unitType, .application(.pi(.unitType, .bound(0)), .bound(0)))
		assert(identity.evaluate(), ==, identity)
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.sigma(.type(1), .type(2))
		assert(Term.projection(product, false).evaluate(), ==, Term.type(1))
		assert(Term.projection(product, true).evaluate(), ==, Term.type(2))
	}
}

import Assertions
import Manifold
import XCTest
