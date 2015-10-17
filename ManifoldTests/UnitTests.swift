//  Copyright © 2015 Rob Rix. All rights reserved.

final class UnitTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.unit


@testable import Manifold
import XCTest
