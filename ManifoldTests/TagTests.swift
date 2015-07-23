//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType([ Term("Enumeration"), Term(.Type(0)) ])
		let actual = Term("Tag").out.typecheck(Expression<Term>.tag.context, against: expected)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}
}


import Assertions
@testable import Manifold
import XCTest
