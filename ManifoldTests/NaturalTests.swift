//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}

	func testZeroTypechecksAsNatural() {
		assert(zero.checkType(Natural, environment, context), ==, .Unroll(Natural, .Variable(.Global("zero"))))
		assert(zero.inferType(environment, context), ==, .Unroll(Natural, .Variable(.Global("zero"))))
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(successor[zero].inferType(environment, context), ==, .Unroll(Natural, .Application(.Unroll(Natural --> Natural, .Variable(.Global("successor"))), .Unroll(Natural, .Variable(.Global("zero"))))))
	}
}

private let module = Module<Term>.natural
private let environment = module.environment
private let context = module.context

private let Natural: Term = "Natural"
private let successor: Term = "successor"
private let zero: Term = "zero"


import Assertions
import Manifold
import XCTest
