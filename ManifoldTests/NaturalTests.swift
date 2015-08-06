//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().map { XCTFail($0.description) }
	}

	func testZeroTypechecksAsNatural() {
		assert(zero.out.checkType("Natural", environment, context), ==, "Natural")
		assert(zero.out.inferType(environment, context), ==, "Natural")
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(successor[zero].out.inferType(environment, context), ==, "Natural")
	}
}

private let module = Expression<Term>.natural
private let environment = module.environment
private let context = module.context

private let successor = Term("successor")
private let zero = Term("zero")


import Assertions
import Manifold
import XCTest
