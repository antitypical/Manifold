//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testZeroTypechecksAsNatural() {
		assert(zero.out.checkType("Natural", context: context), ==, "Natural")
		assert(zero.out.inferType(context), ==, "Natural")
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(Term(.Application(Term("successor"), Term("zero"))).out.inferType(context), ==, "Natural")
	}
}

private let module = Expression<Term>.natural
private let context = module.context

private let zero = Term("zero")


import Assertions
import Manifold
import XCTest
