//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.Type, id).quote, ==, Term.lambda(.type, id))
	}
}


import Assertions
import Manifold
import Prelude
import XCTest
