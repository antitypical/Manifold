//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term(.Unit).out.inferType(), ==, .UnitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term(.UnitType).out.inferType(), ==, .Type(0))
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).out.inferType(), ==, .Type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(Term(.Application(Term(identity), Term(.Unit))).out.inferType(), ==, .UnitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(identity.inferType(), ==, .lambda(Term(.UnitType), const(Term(.UnitType))))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.inferType(), ==, .Lambda(1, Term(.Type(0)), Term(.Lambda(0, Term(1), Term(1)))))
	}

	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Expression.Product(Term(.Unit), Term(false))
		assert(Term(.Projection(Term(product), false)).out.inferType(), ==, .UnitType)
		assert(Term(.Projection(Term(product), true)).out.inferType(), ==, .BooleanType)
	}

	func testIfWithEqualBranchTypesTypechecksToBranchType() {
		assert(Term(.If(Term(true), Term(.Unit), Term(.Unit))).out.inferType(), ==, .UnitType)
	}

	func testIfWithDisjointBranchTypesTypechecksToSumOfBranchTypes() {
		assert(Term(.If(Term(true), Term(.Unit), Term(true))).out.inferType(), ==, Expression.lambda(Term(.BooleanType)) { Term(.If($0, Term(.UnitType), Term(.BooleanType))) })
	}

	func testProductTypechecksToSigmaType() {
		assert(Expression.Product(Term(.Unit), Term(false)).inferType(), ==, Expression.lambda(Term(.UnitType), const(Term(.BooleanType))))
	}

	func testDependentProductTypechecksToSigmaType() {
		let type = Expression.lambda(Term(.BooleanType)) { c in Term(.If(c, Term(.UnitType), Term(.BooleanType))) }
		assert(Expression.Annotation(Term(.Product(Term(true), Term(.Unit))), Term(type)).inferType(), ==, type)
		assert(Expression.Annotation(Term(.Product(Term(false), Term(.Boolean(true)))), Term(type)).inferType(), ==, type)
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

