//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term.unit.typecheck().right, ==, Term.unitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term.unitType.typecheck().right, ==, Term.type)
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term.type.typecheck().right, ==, Term.type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Term.lambda(.unitType, id)
		assert(Term.application(identity, Term.unit).typecheck().right, ==, Term.unitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.lambda(.unitType, id)
		assert(identity.typecheck().right, ==, Term.lambda(.unitType, const(.unitType)))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.typecheck().right, ==, Term.lambda(1, .type, .lambda(0, 1, 1)))
	}

	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Term.product(.unit, false)
		assert(Term.projection(product, false).typecheck().right, ==, Term.unitType)
		assert(Term.projection(product, true).typecheck().right, ==, Term.booleanType)
	}

	func testIfWithEqualBranchTypesTypechecksToBranchType() {
		assert(Term.`if`(.boolean(true), then: .unit, `else`: .unit).typecheck().right, ==, Term.unitType)
	}

	func testIfWithDisjointBranchTypesTypechecksToSumOfBranchTypes() {
		assert(Term.`if`(.boolean(true), then: .unit, `else`: .boolean(true)).typecheck().right, ==, Term.lambda(.booleanType) { Term.`if`($0, then: .unitType, `else`: .booleanType) })
	}
}

import Assertions
import Manifold
import Prelude
import XCTest

