//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testTypechecking() {
		assert(identity.typecheck().right, ==, Term.pi(.type, .pi(.free(0), .free(0))))
	}

	func testPiTypeDescription() {
		assert(identity.typecheck().right?.description, ==, "Π : Type . Π : a . a")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.type, .type).typecheck().right?.description, ==, "Σ Type1 . Type1")
	}

	func testGlobalsPrintTheirNames() {
		assert(Term.free("Global").description, ==, "Global")
	}
}

private let identity = Term.pi(.type, .pi(.bound(0), .bound(0)))
private let constant = Term.pi(.type, .pi(.type, .pi(.bound(1), .pi(.bound(1), .bound(1)))))


import Assertions
import Manifold
import Prelude
import XCTest
