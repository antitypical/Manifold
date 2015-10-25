//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}

	func testZeroTypechecksAsNatural() {
		assert(zero.checkType("Natural", environment, context), ==, "Natural")
		assert(zero.inferType(environment, context), ==, "Natural")
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(successor[zero].inferType(environment, context), ==, "Natural")
	}
}

private let module = Module<Term>.natural
private let environment = module.environment
private let context = module.context

private let successor: Term = "successor"
private let zero: Term = "zero"


import Assertions
import Manifold
import XCTest
