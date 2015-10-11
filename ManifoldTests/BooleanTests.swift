//  Copyright © 2015 Rob Rix. All rights reserved.

final class BooleanTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}


private let module = Expression<Term>.boolean


import Manifold
import XCTest
