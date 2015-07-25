//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testZeroTypechecksAsNatural() {
		assert(zero.typecheck(context).right, ==, "Natural")
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		let typechecked = Term(.Application(Term("successor"), Term("zero"))).out.typecheck(context)
		assert(typechecked.right, ==, "Natural")
	}
}

private let context = Expression<Term>.natural.context

private let zero = Term("zero").out


import Assertions
import Manifold
import XCTest
