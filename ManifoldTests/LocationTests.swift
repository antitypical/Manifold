//  Copyright © 2015 Rob Rix. All rights reserved.

final class LocationTests: XCTestCase {
	func testTraversingAnExpressionReturnsALocationAtTheTraversedExpression() {
		assert(identity.explore().it, ==, identity)
	}
}


import Assertions
@testable import Manifold
import XCTest
