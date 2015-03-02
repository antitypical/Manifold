//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class AlgebraTests: XCTestCase {
	// MARK: Catamorphisms

	func testCountingUnit() {
//		XCTAssertEqual(cata(count)(Term(.Unit)), 1)
	}

	func testCountingBool() {
//		XCTAssertEqual(cata(count)(Bool), 3)
	}


	// MARK: Paramorphisms

	func testBoolIsPrettyPrintedAsSuch() {
//		XCTAssertEqual(para(toString)(Bool), "Bool")
	}
}

private let Unit = Term(.Unit)
private let Bool = Term(.Bool)


private func count(c: Constructor<Int>) -> Int {
	return 1 + c.analysis(
		ifUnit: 0,
		ifFunction: +,
		ifSum: +)
}


private func toString(c: Constructor<(Term, String)>) -> String {
	return c.analysis(
		ifUnit: "Unit",
		ifFunction: { "\($0.1) → \($1.1)" },
		ifSum: {
			($0.0 == Unit && $1.0 == Unit) ?
				"Bool"
			:	"\($0.1) | \($1.1)"
		})
}


// MARK: - Imports

import Box
import Manifold
import XCTest
