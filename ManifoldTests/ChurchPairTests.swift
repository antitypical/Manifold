//  Copyright © 2015 Rob Rix. All rights reserved.

final class ChurchPairTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.churchPair


import Manifold
import XCTest
