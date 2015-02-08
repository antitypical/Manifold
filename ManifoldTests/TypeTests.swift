//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TypeTests: XCTestCase {
	func testVariableTypesHaveOneFreeVariable() {
		let variable = Variable()
		XCTAssertEqual(Type(variable).freeVariables, [ variable ])
	}
}


// MARK: - Imports

import Manifold
import XCTest
