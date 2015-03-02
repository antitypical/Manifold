//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class AlgebraTests: XCTestCase {
	// MARK: Catamorphisms

	func testCountingUnit() {
		XCTAssertEqual(cata(count)(Unit), 1)
	}

	func testCountingBool() {
		XCTAssertEqual(cata(count)(Bool), 3)
	}


	// MARK: Paramorphisms

	func testBoolIsPrettyPrintedAsSuch() {
		XCTAssertEqual(para(toString)(Bool), "Bool")
	}
}

private let Unit = Term.Unit
private let Bool = Term.Bool


private func count(type: Type<Int>) -> Int {
	return 1 + type.analysis(
		ifVariable: const(0),
		ifConstructed: {
			$0.analysis(
				ifUnit: 0,
				ifFunction: +,
				ifSum: +)
		},
		ifUniversal: { $1 })
}


private func toString(type: Type<(Term, String)>) -> String {
	return type.analysis(
		ifVariable: { "τ\($0)" },
		ifConstructed: {
			$0.analysis(
				ifUnit: "Unit",
				ifFunction: { "\($0.1) → \($1.1)" },
				ifSum: {
					($0.0 == Unit && $1.0 == Unit) ?
						"Bool"
					:	"\($0.1) | \($1.1)"
				})
		},
		ifUniversal: {
			"∀\($0).\($1.1)"
		})
}


// MARK: - Imports

import Manifold
import Prelude
import XCTest
