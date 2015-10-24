//  Copyright © 2015 Rob Rix. All rights reserved.

final class PairTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}
}

private let module = Module<Term>.pair


import Manifold
import XCTest
