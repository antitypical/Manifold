//  Copyright © 2015 Rob Rix. All rights reserved.

final class BooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		let churchModule = Module<Term>.churchBoolean
		module.definitions.forEach { symbol, type, value in
			assert(churchModule.context[symbol], ==, type, message: "\(symbol)")
			assert(churchModule.environment[symbol], ==, value, message: "\(symbol)")
		}
	}
}

private let module = Module<Term>.boolean


import Assertions
import Manifold
import XCTest
