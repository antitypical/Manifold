//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchBooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testTrueReturnsItsFirstTermArgument() {
		assert(`true`[.Type, .Boolean(true), .Boolean(false)].evaluate(module.environment), ==, true)
	}

	func testFalseReturnsItsSecondTermArgument() {
		assert(`false`[.Type, .Boolean(true), .Boolean(false)].evaluate(module.environment), ==, false)
	}
}

private let module = Module<Term>.churchBoolean
private let `true`: Term = "true"
private let `false`: Term = "false"


import Assertions
import Manifold
import XCTest
