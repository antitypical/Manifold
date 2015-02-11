//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		let expression = Expression.Variable(0)
		assertEqual(assertRight(typeOf(expression))?.0, [ (0, Scheme([], Type(Variable()))) ])
	}
}


import Manifold
import Prelude
import XCTest
