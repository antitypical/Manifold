//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testPiTypeDescription() {
		assert(identity.typecheck().right?.description, ==, "Π : Type . Π : a . a")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.unit, .unit).typecheck().right?.description, ==, "Σ Unit . Unit")
	}

	func testGlobalsPrintTheirNames() {
		assert(Term.free("Global").description, ==, "Global")
	}
}

private let identity = Term.pi(.type, .pi(0, 0))
private let constant = Term.pi(.type, .pi(.type, .pi(1, .pi(1, 1))))


import Assertions
import Manifold
import XCTest
