//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}
}

private let module = Expression<Term>.list


@testable import Manifold
import XCTest
