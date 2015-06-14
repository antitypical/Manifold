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

	func testAbstractionsNormalizeByEvaluation() {
		let identity = Term.pi(.unitType, .application(.pi(.unitType, .bound(0)), .bound(0)))
		assert(identity.evaluate(), ==, Term.pi(.unitType, .bound(0)))
	}
}

import Assertions
import Manifold
import XCTest
