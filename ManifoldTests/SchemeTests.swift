//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SchemeTests: XCTestCase {
	func testFreeVariablesIncludeTypeFreeVariables() {
		let variable = Variable()
		assertEqual(Scheme([], Type(variable)).freeVariables, Set(variable))
	}
}


// MARK: - Imports

import Manifold
import Set
import XCTest
