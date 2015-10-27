//  Copyright © 2015 Rob Rix. All rights reserved.

final class MaybeTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}


private let module = Module.maybe


import Manifold
import XCTest
