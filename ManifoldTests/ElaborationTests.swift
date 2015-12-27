//  Copyright © 2015 Rob Rix. All rights reserved.

final class ElaborationTests: XCTestCase {
	func testInfersTheTypeOfType() {
		let term: Term = .Type
		assert(try? term.elaborateType(nil, [:], [:]), ==, .Unroll(.Type(1), .Identity(.Type(0))))
	}

	func testChecksLambdasAgainstFunctionTypes() {
		assert(try? Term.Lambda(.Local(0), .Type, 0).elaborateType(.Type --> .Type, [:], [:]), ==, .Unroll(.Type --> .Type, .Identity(.Lambda(.Unroll(.Type, .Identity(.Type(0))), .Unroll(.Type, .Abstraction(.Local(0), .Unroll(.Type, .Variable(.Local(0)))))))))
	}
}


import Assertions
import Manifold
import XCTest
