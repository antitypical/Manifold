//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testUnitTermEvaluatesToItself() {
		assert(Term(.Unit).out.evaluate(), ==, .Unit)
	}

	func testUnitTypeEvaluatesToItself() {
		assert(Term(.UnitType).out.evaluate(), ==, .UnitType)
	}

	func testTypeEvaluatesToItself() {
		assert(Term(.Type(0)).out.evaluate(), ==, .Type(0))
	}

	func testApplicationOfIdentityAbstractionToUnitTermEvaluatesToUnitTerm() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(Expression.Application(Term(identity), Term(.Unit)).evaluate(), ==, .Unit)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		assert(identity.evaluate(), ==, identity)
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Expression.Product(Term(.Unit), Term(false))
		assert(Expression.Projection(Term(product), false).evaluate(), ==, .Unit)
		assert(Expression.Projection(Term(product), true).evaluate(), ==, false)
	}

	func testIfEvaluatesToCorrectBranch() {
		assert(Expression.If(Term(true), Term(true), Term(false)).evaluate(), ==, true)
		assert(Expression.If(Term(false), Term(true), Term(false)).evaluate(), ==, false)
	}
}

import Assertions
import Manifold
import Prelude
import XCTest
