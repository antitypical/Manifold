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

	func testCaseConstruction() {
		assert(NaturalDescription, ==, Description.Argument(.BooleanType) { .If($0, .UnitType, .Argument(.Recursive(.End), id)) })
	}
}

private let NaturalDescription: Description = [
	"zero": .End,
	"successor": .Argument(.Recursive(.End), id),
]



import Assertions
@testable import Manifold
import Prelude
import XCTest
