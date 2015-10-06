//  Copyright © 2015 Rob Rix. All rights reserved.

final class DatatypeTests: XCTestCase {
	func testDatatypeWithZeroConstructorsIsUnitType() {
		assert(Datatype(constructors: []).value("A"), ==, .UnitType)
	}
}


import Assertions
@testable import Manifold
import XCTest
