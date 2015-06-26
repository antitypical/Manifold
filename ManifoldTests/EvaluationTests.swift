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
		let identity = Term.pi(.unitType, id)
		assert(Term.application(identity, Term.unit).evaluate(), ==, Term.unit)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.pi(.unitType, id)
		assert(identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		assert(identity.evaluate(), ==, identity)
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.product(.unit, false)
		assert(Term.projection(product, false).evaluate(), ==, Term.unit)
		assert(Term.projection(product, true).evaluate(), ==, false)
	}

	func testIfEvaluatesToCorrectBranch() {
		assert(Term.`if`(.boolean(true), then: .boolean(true), `else`: .boolean(false)).evaluate(), ==, Term.boolean(true))
		assert(Term.`if`(.boolean(false), then: .boolean(true), `else`: .boolean(false)).evaluate(), ==, Term.boolean(false))
	}
}

import Assertions
import Manifold
import Prelude
import XCTest
