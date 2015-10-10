//  Copyright © 2015 Rob Rix. All rights reserved.

final class DatatypeTests: XCTestCase {
	func testDatatypeWithZeroConstructorsIsUnitType() {
		assert(Datatype(constructors: []).value("A"), ==, .UnitType)
	}

	func testDatatypeWithOneConstructorIsTypeOfConstructedValue() {
		assert(Datatype(constructors: [ ("a", .Argument(.BooleanType, const(.End))) ]).value("A"), ==, .Product(.BooleanType, .UnitType))
	}

	func testDatatypeWithTwoConstructorsIsFunctionFromBooleanToTypesOfConstructedValues() {
		let List: Datatype<Term> = [
			"nil": .End,
			"cons": .Argument(.BooleanType, const(.Recursive(.End)))
		]
		assert(List.value("List"), ==, .lambda(.BooleanType, { .If($0, .UnitType, .Product(.BooleanType, .Product("List", .UnitType))) }))
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
