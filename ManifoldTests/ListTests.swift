//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0.description) }
	}

	func testTypeOfConsIsParameterizedByAType() {
		assert(module.context["cons"], ==, .lambda(.Type, { A in .lambda(A, const(.lambda(.Application("List", A), const(.Application("List", A))))) }))
	}
}

private let module = Module<Term>.list


import Assertions
@testable import Manifold
import Prelude
import XCTest
