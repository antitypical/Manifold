//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.Type, id).quote, ==, Term.lambda(.type, id))
	}

	func testNestedQuotation() {
		assert(Value.pi(.Type) { Value.pi(.Type, const($0)) }.quote, ==, Term.lambda(.type) { Term.lambda(.type, const($0)) })
	}
}


import Assertions
import Manifold
import Prelude
import XCTest
