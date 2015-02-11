//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		let expression = Expression(variable: 0)
		assertEqual(assertRight(typeOf(expression))?.0, Type(Variable()))
	}

	func testApplicationsAreAssignedAFreshTypeVariable() {
		let function = Expression(variable: 0) // fixme: this should be an abstraction
		let variable = Expression(variable: 1)
		let application = Expression(apply: function, to: variable)
		assertEqual(assertRight(typeOf(application))?.0, Type(Variable()))
	}
}


import Manifold
import Prelude
import XCTest
