//  Copyright © 2015 Rob Rix. All rights reserved.

final class PreludeTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.prelude


import Manifold
import XCTest
