//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testListTypechecksAsAHigherOrderType() {
		let kind = Expression<Term>.Variable("List").typecheck(Expression.list.context)
		assert(kind.left, ==, nil)
		assert(kind.right, ==, Expression<Term>.lambda(.Type(0), const(.Type(0))))
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest
