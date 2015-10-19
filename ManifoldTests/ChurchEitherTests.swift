//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchEitherTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.churchEither


import Manifold
import XCTest
