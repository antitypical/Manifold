//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.Type, id).quote, ==, Value.pi(.Type, id).quote)
	}

	func testNestedQuotation() {
		assert(Value.pi(.Type) { Value.pi(.Type, const($0)) }.quote, ==, Term(.Pi(Box(.type), Box(Term(.Pi(Box(.type), Box(Term(.Bound(0)))))))))
	}

	func testQuotationMapsQuotedVariablesToBoundVariables() {
		assert(Value.free(.Quote(1)).quote, ==, Term(.Bound(1)))
	}

	func testQuotationMapsNestedBoundVariablesToBoundVariables() {
		assert(Value.pi(.type) { _ in Value.pi(.type, id) }.quote, ==, Term(.Pi(Box(.type), Box(Term(.Pi(Box(.type), Box(Term(.Bound(1)))))))))
	}
}


import Assertions
import Box
import Either
import Manifold
import Prelude
import XCTest
