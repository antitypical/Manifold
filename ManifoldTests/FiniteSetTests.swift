//  Copyright © 2015 Rob Rix. All rights reserved.

final class FiniteSetTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.finiteSet


import Manifold
import XCTest
