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


	func testMutuallyExclusiveTypeConstructorsAreAnError() {
		let illTyped = Expression(apply: Expression(constant: .Unit), to: Expression(constant: .Unit))
		let inferred = infer(illTyped)
		assert(inferred.assumptions.count, ==, 0)

		let solved = solve(inferred.constraints)
		let e: Error? = solved.either({ $0 }, { failure("expected mutually exclusive types but got \($0)") })
		assertNotNil(solved.left)
		assert(solved.right, ==, nil)
	}
}


let identity = Expression(abstract: 0, body: Expression(variable: 0))


// MARK: - Imports

import Assertions
import Manifold
import Prelude
import XCTest
