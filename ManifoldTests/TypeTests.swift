//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TypeTests: XCTestCase {
	func testVariableTypesHaveOneFreeVariable() {
		let variable = Variable()
		assertEqual(Type(variable).freeVariables, Set(variable))
	}

	func testFunctionTypesDistributeFreeVariables() {
		let variable = Variable()
		assertEqual(Type(function: Type(variable), Type(variable)).freeVariables, Set(variable))
	}
}


// MARK: - Imports

import Manifold
import Set
import XCTest
