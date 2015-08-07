//  Copyright © 2015 Rob Rix. All rights reserved.

final class DescriptionTests: XCTestCase {
	func testOneEmptyBranchProducesUnitType() {
		let UnitDescription: Description<Term> = [
			"unit": .End,
		]

		assert(UnitDescription.term("Unit"), ==, Term(.UnitType))
	}
}


import Assertions
@testable import Manifold
import XCTest
