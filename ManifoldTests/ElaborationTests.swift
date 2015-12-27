//  Copyright © 2015 Rob Rix. All rights reserved.

final class ElaborationTests: XCTestCase {
	func testInfersTheTypeOfType() {
		let term: Term = .Type
		assert(try? term.elaborateType(nil, [:], [:]), ==, AnnotatedTerm<Term>.Unroll(.Type(1), .Identity(.Type(0))))
	}
}


import Assertions
import Manifold
import XCTest
