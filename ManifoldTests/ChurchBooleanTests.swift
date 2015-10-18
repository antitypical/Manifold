//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchBooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testTrueReturnsItsFirstTermArgument() {
		assert(`true`[.Type, .Boolean(true), .Boolean(false)].evaluate(module.environment), ==, true)
	}
}

private let module = Module<Term>.churchBoolean
private let `true`: Term = "true"


import Assertions
import Manifold
import XCTest
