//  Copyright © 2015 Rob Rix. All rights reserved.

final class VectorTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module.vector


import Manifold
import XCTest
