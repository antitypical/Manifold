//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ValueTests: XCTestCase {
	func testQuotation() {
		assert(Value.pi(.type, id).quote, ==, Value.pi(.type, id).quote)
	}

	func testNestedQuotation() {
		assert(Value.pi(.type) { Value.pi(.type, const($0)) }.quote, ==, Term.pi(.type, .pi(.type, .bound(1))))
	}

	func testQuotationMapsNestedBoundVariablesToBoundVariables() {
		assert(Value.pi(.type) { _ in Value.pi(.type, id) }.quote, ==, Term.pi(.type, .pi(.type, .bound(0))))
	}


	func testNullaryProductIsUnitTerm() {
		assert(Value.product([]).quote, ==, Term.unitTerm)
	}

	func testUnaryProductEndsWithUnitTerm() {
		assert(Value.product([ Value.type ]).quote, ==, Term.sigma(.type, .unitTerm))
	}

	func testTernaryProductAssociatesToTheRight() {
		assert(Value.product([ Value.type, Value.type, Value.type ]).quote, ==, Term.sigma(.type, .sigma(.type, .sigma(.type, .unitTerm))))
	}
}


import Assertions
import Either
import Manifold
import Prelude
import XCTest
