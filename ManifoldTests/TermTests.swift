//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testPiTypeDescription() {
		assert(identity.description, ==, "Π 1 : Type . Π 0 : a . a")
		assert(identity.typecheck().right?.description, ==, "Π 1 : Type . Π 0 : a . b")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.unit, .unit).typecheck().right?.description, ==, "Σ 0 : Unit . Unit")
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

	func testHigherOrderConstruction() {
		assert(identity, ==, Term.pi(.type, Term.pi(0, 0)))
	}
}

private let identity = Term.function(.type) { Term.function($0, id) }
private let constant = Term.pi(.type, .pi(.type, .pi(1, .pi(1, 1))))


import Assertions
import Manifold
import Prelude
import XCTest
