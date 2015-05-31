//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.type, id).quote, ==, Value.pi(.type, id).quote)
	}

	func testNestedQuotation() {
		assert(Value.pi(.type) { Value.pi(.type, const($0)) }.quote, ==, Term(.Pi(Box(.type), Box(Term(.Pi(Box(.type), Box(Term(.Bound(1)))))))))
	}

	func testQuotationMapsNestedBoundVariablesToBoundVariables() {
		assert(Value.pi(.type) { _ in Value.pi(.type, id) }.quote, ==, Term(.Pi(Box(.type), Box(Term(.Pi(Box(.type), Box(Term(.Bound(0)))))))))
	}


	func testNullaryProductIsUnitTerm() {
		assert(Value.product([]).quote, ==, Term.unitTerm)
	}

	func testUnaryProductEndsWithUnitTerm() {
		assert(Value.product([ Value.type ]).quote, ==, Term(.Sigma(Box(.type), Box(.unitTerm))))
	}
}


import Assertions
import Box
import Either
import Manifold
import Prelude
import XCTest
