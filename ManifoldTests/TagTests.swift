//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType([ Term("Enumeration"), Term(.Type(0)) ])
		let actual = Term("Tag").out.typecheck(context, against: expected)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}

	func testBranchesProducesAType() {
		assert(Term("Branches")[Term("[]")[Term("String")]].out.typecheck(context, against: .Type(0)).left, ==, nil)
	}
}


private let context = Expression<Term>.tag.context


import Assertions
@testable import Manifold
import XCTest
