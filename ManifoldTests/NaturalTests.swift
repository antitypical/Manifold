//  Copyright © 2015 Rob Rix. All rights reserved.

final class NaturalTests: XCTestCase {
	func testZeroTypechecksAsNatural() {
		assert(zero.typecheck(Expression<Term>.naturalContext).right, ==, .Variable("Natural"))
	}
}


let zero: Expression<Term> = .Variable("zero")


import Assertions
import Manifold
import XCTest
