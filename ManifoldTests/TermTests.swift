//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testPiTypeDescription() {
		assert(identity.description, ==, "Π : Type . Π : a . a")
		assert(identity.typecheck().right?.description, ==, "Π : Type . Π : a . b")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.unit, .unit).typecheck().right?.description, ==, "Σ Unit . Unit")
	}

	func testGlobalsPrintTheirNames() {
		assert(Term.free("Global").description, ==, "Global")
	}


	func testNullarySumsAreUnitType() {
		assert(Term.sum([]), ==, .unitType)
	}

	func testUnarySumsAreTheIdentityConstructor() {
		assert(Term.sum([ .booleanType ]), ==, .booleanType)
	}

	func testNArySumsAreSigmas() {
		assert(Term.sum([ .booleanType, .booleanType ]), ==, Term.sigma(.booleanType, .`if`(0, then: .booleanType, `else`:.booleanType)))
	}
}

private let identity = Term.pi(.type, .pi(0, 0))
private let constant = Term.pi(.type, .pi(.type, .pi(1, .pi(1, 1))))


import Assertions
import Manifold
import XCTest
