//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SchemeTests: XCTestCase {
	func testFreeVariablesIncludeTypeFreeVariables() {
		let variable = Variable()
		assertEqual(Scheme([], Type(variable)).freeVariables, Set([ variable ]))
	}

	func testFreeVariablesExcludeBoundVariables() {
		let (a, b) = (Variable(), Variable())
		assertEqual(Scheme([ a ], Type(function: Type(a), Type(b))).freeVariables, Set([ b ]))
	}
}


// MARK: - Imports

import Manifold
import Set
import XCTest
