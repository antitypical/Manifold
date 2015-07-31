//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testZeroTypechecksAsNatural() {
		assert(zero.inferType(context).right, ==, "Natural")
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		let typechecked = Term(.Application(Term("successor"), Term("zero"))).out.inferType(context)
		assert(typechecked.right, ==, "Natural")
	}
}

private let module = Expression<Term>.natural
private let context = module.context

private let zero = Term("zero").out


import Assertions
import Manifold
import XCTest
