//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.Type, id).quote, ==, Term.lambda(.type, id))
	}

	func testNestedQuotation() {
		assert(Value.pi(.Type) { Value.pi(.Type, const($0)) }.quote, ==, Term.lambda(.type) { Term.lambda(.type, const($0)) })
	}

	func testQuotationMapsQuotesToVariables() {
		assert(Value.Quote(1).quote, ==, Term(.Variable(-2)))
	}

	func testQuotationMapsNestedQuotesToVariables() {
		assert(Value.Pi(Box(.Type)) { _ in Value.Pi(Box(.Type), unit) }.quote, ==, Term(.Pi(0, Box(.type), Box(Term(.Pi(1, Box(.type), Box(Term(.Variable(0)))))))))
	}
}


import Assertions
import Box
import Manifold
import Prelude
import XCTest
