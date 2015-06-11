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
}

import Assertions
import Manifold
import XCTest
