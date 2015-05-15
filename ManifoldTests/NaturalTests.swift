//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testReferencesToZeroAreWellTyped() {
		assert(Zero.typecheck(naturalEnvironment).right?.quote, ==, Term(.Free("Natural")))
//		(Zero.typecheck(naturalEnvironment).right?.quote).map(println)
//		(Zero.evaluate(naturalEnvironment).right?.quote).map(println)
	}

	func testReferencesToZeroEvaluateToConstantValueOfZero() {
		let result = Zero.evaluate(naturalEnvironment)
		let constant = result.right?.constant
		assert(constant?.0 as? Int, ==, 0)
	}
}

let Zero = Term(.Free("Zero"))


import Assertions
import Manifold
import XCTest
