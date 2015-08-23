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

		assert(Term(BooleanDescription).out, ==, Expression.lambda(Term(.BooleanType)) { Term(.If($0, Term(.UnitType), Term(.UnitType))) })
	}
}


import Assertions
@testable import Manifold
import XCTest
