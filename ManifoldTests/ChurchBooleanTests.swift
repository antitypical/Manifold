//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchBooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.churchBoolean


import Manifold
import XCTest
