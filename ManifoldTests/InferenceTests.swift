//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		assertNotNil(infer(Expression(variable: 0)).0.variable)
	}

	func testApplicationsAreAssignedAFreshTypeVariable() {
		let application = Expression(apply: identity, to: Expression(constant: .Unit))
		assertNotNil(infer(application).0.variable)
	}

	func testAbstractionsAreAssignedAFunctionType() {
		assertNotNil(infer(identity).0.function)
	}
}


let identity = Expression(abstract: 0, body: Expression(variable: 0))


// MARK: - Imports

import Assertions
import Manifold
import Prelude
import XCTest
