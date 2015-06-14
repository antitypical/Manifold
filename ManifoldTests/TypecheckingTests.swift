//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term.unitTerm.typecheck().right, ==, Term.unitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term.unitType.typecheck().right, ==, Term.type)
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term.type.typecheck().right, ==, Term.type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(Term.application(identity, Term.unitTerm).typecheck().right, ==, Term.unitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.pi(.unitType, .bound(0))
		assert(identity.typecheck().right, ==, Term.pi(.unitType, .unitType))
	}
}

import Assertions
import Manifold
import XCTest

