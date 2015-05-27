//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testReferencesToZeroAreWellTyped() {
		let value = Zero.typecheck(naturalEnvironment.global, from: 0).right
		let type = Natural.evaluate(naturalEnvironment)
		assert(value, !=, nil)
		assert(value?.quote, ==, type.quote)
	}

	func testReferencesToOneAreWellTyped() {
		let value = One.typecheck(naturalEnvironment.global, from: 0).right
		let type = Natural.evaluate(naturalEnvironment)
		assert(value, !=, nil)
		assert(type, !=, nil)
		assert(value?.quote, ==, type.quote)
	}

	func testSuccessorOfZeroIsOne() {
		let value = Term.application(Successor, Zero).evaluate(naturalEnvironment)
		let one = One.evaluate(naturalEnvironment)
		assert(value, !=, nil)
		assert(one, !=, nil)
		assert(value.quote, ==, one.quote)
	}
}

let Natural = Term.free("Natural")
let Zero = Term.free("Zero")
let One = Term.free("One")
let Successor = Term.free("Successor")


import Assertions
import Manifold
import XCTest
