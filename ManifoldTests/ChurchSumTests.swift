//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchSumTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.churchSum


import Manifold
import XCTest
