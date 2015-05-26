//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testReferencesToZeroAreWellTyped() {
		let value = Zero.typecheck(naturalEnvironment).right
		let type = Natural.evaluate(naturalEnvironment).right
		assert(value, !=, nil)
		assert(type, !=, nil)
		assert(value?.quote, ==, type?.quote)
	}
}

let Natural = Term.free("Natural")
let Zero = Term.free("Zero")


import Assertions
import Manifold
import XCTest
