//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchListTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.churchList


import Manifold
import XCTest
