//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		assertNotNil(infer(0).0.variable)
	}

	func testApplicationsAreAssignedAFreshTypeVariable() {
		let application = 0 <| 0 // fixme: left operand should be an abstraction
		assertNotNil(infer(application).0.variable)
	}

	func testAbstractionsAreAssignedAFunctionType() {
		let abstraction = 0 .. 0
		assertNotNil(infer(abstraction).0.function)
	}
}


// MARK: - Imports

import Assertions
import Manifold
import Prelude
import XCTest
