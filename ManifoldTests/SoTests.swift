//  Copyright © 2015 Rob Rix. All rights reserved.

final class SoTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.so


import Manifold
import XCTest
