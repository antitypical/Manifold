//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchBooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testTrueReturnsItsFirstTermArgument() {
		assert(`true`[.Type, identity, constant].evaluate(module.environment), ==, identity)
	}

	func testFalseReturnsItsSecondTermArgument() {
		assert(`false`[.Type, identity, constant].evaluate(module.environment), ==, constant)
	}
}

private let module = Module<Term>.churchBoolean
private let `true`: Term = "true"
private let `false`: Term = "false"


import Assertions
import Manifold
import XCTest
