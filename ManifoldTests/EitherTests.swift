//  Copyright © 2015 Rob Rix. All rights reserved.

final class EitherTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Module<Term>.either


@testable import Manifold
import XCTest
