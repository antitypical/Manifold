//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term.Unit.out.evaluate(), ==, .Unit)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term.UnitType.out.evaluate(), ==, .UnitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term(.Type(0)).out.evaluate(), ==, .Type(0))
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Term.lambda(.UnitType, id)
		assert(Expression.Application(identity, .Unit).evaluate(), ==, .Unit)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Term.lambda(.UnitType, id)
		assert(identity.out.evaluate(), ==, identity.out)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		assert(identity.out.evaluate(), ==, identity.out)
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.Product(.Unit, false)
		assert(Expression.Projection(product, false).evaluate(), ==, .Unit)
		assert(Expression.Projection(product, true).evaluate(), ==, false)
	}

	func testIfEvaluatesToCorrectBranch() {
		assert(Expression<Term>.If(true, true, false).evaluate(), ==, true)
		assert(Expression<Term>.If(false, true, false).evaluate(), ==, false)
	}
}

import Assertions
import Manifold
import Prelude
import XCTest
