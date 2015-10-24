//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term.Unit.evaluate(), ==, .Unit)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term.UnitType.evaluate(), ==, .UnitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term(.Type(0)).evaluate(), ==, .Type(0))
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Term.lambda(.UnitType, id)
		assert(Term.Application(identity, .Unit).evaluate(), ==, .Unit)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.lambda(.UnitType, id)
		assert(identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		assert(identity.evaluate(), ==, identity)
	}
}

import Assertions
import Manifold
import Prelude
import XCTest
