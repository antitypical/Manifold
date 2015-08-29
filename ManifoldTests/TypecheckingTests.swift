//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term.Unit.out.inferType(), ==, .UnitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term.UnitType.out.inferType(), ==, .Type(0))
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).out.inferType(), ==, .Type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Term.lambda(.UnitType, id)
		assert(Term.Application(identity, .Unit).out.inferType(), ==, .UnitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.lambda(.UnitType, id)
		assert(identity.out.inferType(), ==, .lambda(.UnitType, const(.UnitType)))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.out.inferType(), ==, .Lambda(1, .Type, .Lambda(0, 1, 1)))
	}

	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Term.Product(.Unit, .Product(.Unit, .Unit))
		assert(Term.Projection(product, false).out.inferType(), ==, .UnitType)
		assert(Term.Projection(product, true).out.inferType(), ==, .Lambda(0, .UnitType, .UnitType))
	}

	func testProductTypechecksToSigmaType() {
		assert(Term.Product(.Unit, .Product(.Unit, .Unit)).out.inferType(), ==, Term.lambda(.UnitType, const(.lambda(.UnitType, const(.UnitType)))).out)
	}

//	func testDependentProductTypechecksToSigmaType() {
//		let type = Term.lambda(.BooleanType) { c in .If(c, .UnitType, .BooleanType) }
//		assert(Term.Annotation(.Product(true, .Unit), type).out.inferType(), ==, type.out)
//		assert(Term.Annotation(.Product(false, true), type).out.inferType(), ==, type.out)
//	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

