//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term.Unit.inferType(), ==, .UnitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term.UnitType.inferType(), ==, .Type(0))
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).inferType(), ==, .Type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Term.lambda(.UnitType, id)
		assert(Term.Application(identity, .Unit).inferType(), ==, .UnitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.lambda(.UnitType, id)
		assert(identity.inferType(), ==, .lambda(.UnitType, const(.UnitType)))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.inferType(), ==, .Lambda(1, .Type, .Lambda(0, 1, 1)))
	}

	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Term.Product(.Unit, false)
		assert(Term.Projection(product, false).inferType(), ==, .UnitType)
		assert(Term.Projection(product, true).inferType(), ==, .BooleanType)
	}

	func testIfWithEqualBranchTypesTypechecksToBranchType() {
		assert(Term.If(true, .Unit, .Unit).inferType(), ==, .UnitType)
	}

	func testIfWithDisjointBranchTypesTypechecksToSumOfBranchTypes() {
		assert(Term.If(true, .Unit, true).inferType(), ==, Term.lambda(.BooleanType) { .If($0, .UnitType, .BooleanType) })
	}

	func testProductTypechecksToSigmaType() {
		assert(Term.Product(.Unit, false).inferType(), ==, Term.lambda(.UnitType, const(.BooleanType)))
	}

	func testDependentProductTypechecksToSigmaType() {
		let type = Term.lambda(.BooleanType) { c in .If(c, .UnitType, .BooleanType) }
		assert(Term.Annotation(.Product(true, .Unit), type).inferType(), ==, type)
		assert(Term.Annotation(.Product(false, true), type).inferType(), ==, type)
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

