//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testConstructsOneTagPerLabel() {
		assert(Tag.tags([ "a", "b", "c" ]).count, ==, 3)
	}
}


import Assertions
@testable import Manifold
import XCTest
