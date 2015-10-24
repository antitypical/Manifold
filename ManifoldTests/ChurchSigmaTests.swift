//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchSigmaTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.churchSigma


import Manifold
import XCTest
