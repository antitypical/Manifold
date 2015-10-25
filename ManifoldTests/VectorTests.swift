//  Copyright © 2015 Rob Rix. All rights reserved.

final class VectorTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.vector


import Manifold
import XCTest
