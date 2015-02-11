//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		let expression = Expression(variable: 0)
		assertEqual(assertRight(typeOf(expression))?.0, Type(Variable()))
	}
}


import Manifold
import Prelude
import XCTest
