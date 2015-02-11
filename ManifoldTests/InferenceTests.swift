//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class InferenceTests: XCTestCase {
	func testVariablesAreAssignedAFreshTypeVariable() {
		assertEqual(assertRight(typeOf(0))?.0, Type(Variable()))
	}

	func testApplicationsAreAssignedAFreshTypeVariable() {
		let application = 0 <| 0 // fixme: left operand should be an abstraction
		assertEqual(assertRight(typeOf(application))?.0, Type(Variable()))
	}

	func testAbstractionsAreAssignedAFunctionType() {
		let abstraction = 0 .. 0
		assertEqual(assertRight(typeOf(abstraction))?.0, Type(Variable()) --> Type(Variable()))
	}
}


import Manifold
import Prelude
import XCTest
