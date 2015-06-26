//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testPiTypeDescription() {
		assert(identity.description, ==, "Π 1 : Type . Π 0 : a . a")
		assert(identity.typecheck().right?.description, ==, "Π 1 : Type . Π 0 : a . b")
	}

	func testSigmaTypeDescription() {
		assert(Term.product(.unit, .unit).typecheck().right?.description, ==, "Σ 0 : Unit . Unit")
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
		assert(Term.sum([ .booleanType, .booleanType ]), ==, Term.sigma(0, .booleanType, .`if`(0, then: .booleanType, `else`:.booleanType)))
	}

	func testHigherOrderConstruction() {
		assert(identity, ==, Term.pi(1, .type, Term.pi(0, 0, 0)))
	}
}

let identity = Term.pi(.type) { Term.pi($0, id) }
let constant = Term.pi(3, .type, .pi(2, .type, .pi(1, 3, .pi(0, 2, 1))))


import Assertions
import Manifold
import Prelude
import XCTest
