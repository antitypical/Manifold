//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testReferencesToZeroAreWellTyped() {
		let value = Zero.typecheck(naturalEnvironment).right
		assert(value, !=, nil)
		assert(value?.quote, ==, .type)
	}
}

let Zero = Term.free("Zero")


import Assertions
import Manifold
import XCTest
