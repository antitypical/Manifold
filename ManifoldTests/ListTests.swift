//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testListTypechecks() {
		let kind = Expression<Term>.Variable("List").typecheck(Expression.list.context)
		assert(kind.left, ==, nil)
	}
}

import Assertions
@testable import Manifold
import XCTest
