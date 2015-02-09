//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		assertEqual(assertRight(typeOf(Expression.Value(.Variable(0))))?.analysis(const(true), const(false)), true)
	}
}


import Manifold
import Prelude
import XCTest
