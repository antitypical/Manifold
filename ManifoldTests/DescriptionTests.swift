//  Copyright © 2015 Rob Rix. All rights reserved.

final class DescriptionTests: XCTestCase {
	func testOneEmptyBranchProducesUnitType() {
		let UnitDescription: Description = [
			"unit": .End,
		]

		assert(UnitDescription.out, ==, .UnitType)
	}

	func testTwoEmptyBranchesProduceBooleanType() {
		let BooleanDescription: Description = [
			"true": .End,
			"false": .End,
		]

		assert(Term(term: BooleanDescription).out, ==, Expression.lambda(.BooleanType) { .If($0, .UnitType, .UnitType) })
	}
}


import Assertions
@testable import Manifold
import XCTest
