//  Copyright © 2015 Rob Rix. All rights reserved.

final class PreludeTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module.prelude


import Manifold
import XCTest
