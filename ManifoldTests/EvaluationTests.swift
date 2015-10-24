//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTypeEvaluatesToItself() {
		assert(Term.UnitType.evaluate(), ==, .UnitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term(.Type(0)).evaluate(), ==, .Type(0))
	}

	func testApplicationOfIdentityAbstractionToTermEvaluatesToTerm() {
		let identity = Term.lambda(.Type, id)
		assert(Term.Application(identity, .Type).evaluate(), ==, .Type)
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
