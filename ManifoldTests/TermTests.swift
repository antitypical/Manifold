//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.description, ==, "Π b : Type . Π a : b . a")
		assert(identity.typecheck().right?.description, ==, "Π b : Type . Π a : b . b")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.unit, const(.unit)).typecheck().right?.description, ==, "Σ a : Unit . Unit")
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
		assert(identity, ==, Term.lambda(1, .type, Term.lambda(0, 1, 0)))
		assert(constant, ==, Term.lambda(3, .type, .lambda(2, .type, .lambda(1, 3, .lambda(0, 2, 1)))))
	}
}

let identity = Term.lambda(.type) { Term.lambda($0, id) }
let constant = Term.lambda(.type) { A in Term.lambda(.type) { B in Term.lambda(A) { a in Term.lambda(B, const(a)) } } }


import Assertions
import Manifold
import Prelude
import XCTest
