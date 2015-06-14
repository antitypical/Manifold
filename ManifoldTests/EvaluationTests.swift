//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term.unit.evaluate(), ==, Term.unit)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term.unitType.evaluate(), ==, Term.unitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate(), ==, Term.type)
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Term.pi(.unitType, 0)
		assert(Term.application(identity, Term.unit).evaluate(), ==, Term.unit)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.pi(.unitType, 0)
		assert(identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		let identity = Term.pi(.unitType, .application(.pi(.unitType, 0), 0))
		assert(identity.evaluate(), ==, identity)
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.sigma(.unit, false)
		assert(Term.projection(product, false).evaluate(), ==, Term.unit)
		assert(Term.projection(product, true).evaluate(), ==, false)
	}
}

import Assertions
import Manifold
import XCTest
