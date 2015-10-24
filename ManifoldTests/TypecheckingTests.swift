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
		assert(identity.inferType(), ==, .Lambda(0, .Type, .Lambda(-1, 0, 0)))
	}

	func testIfWithEqualBranchTypesTypechecksToBranchType() {
		assert(Term.If(true, .Unit, .Unit).inferType(), ==, .UnitType)
	}

	func testIfWithDisjointBranchTypesTypechecksToSumOfBranchTypes() {
		assert(Term.If(true, .Unit, true).inferType(), ==, Term.lambda(.BooleanType) { .If($0, .UnitType, .BooleanType) })
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

