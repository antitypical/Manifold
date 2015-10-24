//  Copyright © 2015 Rob Rix. All rights reserved.

final class EitherTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		let churchModule = Module<Term>.churchEither
		module.definitions.forEach { symbol, type, value in
			assert(churchModule.context[symbol], ==, type)
			assert(churchModule.environment[symbol], ==, value)
		}
	}
}

private let module = Module<Term>.either


import Assertions
@testable import Manifold
import XCTest
