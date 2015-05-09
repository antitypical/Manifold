//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.Type, id).quote, ==, Term.lambda(.type, id))
	}

	func testNestedQuotation() {
		// α-convertible to Term.lambda(.type) { Term.lambda(.type, const($0)) } — inside out vs. outside in assignment of indices
		assert(Value.pi(.Type) { Value.pi(.Type, const($0)) }.quote, ==, Term(.Pi(0, Box(.type), Box(Term(.Pi(1, Box(.type), Box(Term(.Variable(1)))))))))
	}
}


import Assertions
import Box
import Manifold
import Prelude
import XCTest
