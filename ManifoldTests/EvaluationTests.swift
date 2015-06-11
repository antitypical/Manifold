//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term.unitTerm.evaluate().quote, ==, Term.unitTerm)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term.unitType.evaluate().quote, ==, Term.unitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate().quote, ==, Term.type)
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(Term.application(identity, Term.unitTerm).evaluate().quote, ==, Term.unitTerm)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(identity.evaluate().quote, ==, identity)
	}

	func testAbstractionsNormalizeByEvaluation() {
		let identity = Term.pi(.unitType, .application(.pi(.unitType, .bound(0)), .bound(0)))
		assert(identity.evaluate().quote, ==, Term.pi(.unitType, .bound(0)))
	}
}

import Assertions
import Manifold
import XCTest
