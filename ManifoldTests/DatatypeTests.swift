//  Copyright © 2015 Rob Rix. All rights reserved.

final class DatatypeTests: XCTestCase {
	func testDatatypeWithZeroConstructorsIsUnitType() {
		assert(Datatype(constructors: []).value("A"), ==, .UnitType)
	}

	func testDatatypeWithOneConstructorIsTypeOfConstructedValue() {
		assert(Datatype(constructors: [ ("a", .Argument(.BooleanType, const(.End))) ]).value("A"), ==, .Product(.BooleanType, .UnitType))
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
