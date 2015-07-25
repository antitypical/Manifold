//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testZeroTypechecksAsNatural() {
		assert(zero.typecheck(Expression<Term>.natural.context).right, ==, .Variable("Natural"))
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		let typechecked = Term(.Application(Term(.Variable("successor")), Term(.Variable("zero")))).out.typecheck(Expression<Term>.natural.context)
		assert(typechecked.right, ==, .Variable("Natural"))
	}
}


private let zero = Term("zero").out


import Assertions
import Manifold
import XCTest
