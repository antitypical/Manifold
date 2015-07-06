//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testUnitTermTypechecksToUnitType() {
		assert(Term(.Unit).out.typecheck().right, ==, .UnitType)
	}

	func testUnitTypeTypechecksToType() {
		assert(Term(.UnitType).out.typecheck().right, ==, .Type(0))
	}

	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).out.typecheck().right, ==, .Type(1))
	}

	func testApplicationOfIdentityAbstractionToUnitTermTypechecksToUnitType() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(Term(.Application(Term(identity), Term(.Unit))).out.typecheck().right, ==, .UnitType)
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Expression.lambda(Term(.UnitType), id)
		assert(identity.typecheck().right, ==, .lambda(Term(.UnitType), const(Term(.UnitType))))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.typecheck().right, ==, .Lambda(1, Term(.Type(0)), Term(.Lambda(0, Term(1), Term(1)))))
	}

	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Expression.Product(Term(.Unit), Term(false))
		assert(Term(.Projection(Term(product), false)).out.typecheck().right, ==, .UnitType)
		assert(Term(.Projection(Term(product), true)).out.typecheck().right, ==, .BooleanType)
	}

	func testIfWithEqualBranchTypesTypechecksToBranchType() {
		assert(Term(.If(Term(true), Term(.Unit), Term(.Unit))).out.typecheck().right, ==, .UnitType)
	}

	func testIfWithDisjointBranchTypesTypechecksToSumOfBranchTypes() {
		assert(Term(.If(Term(true), Term(.Unit), Term(true))).out.typecheck().right, ==, Expression.lambda(Term(.BooleanType)) { Term(.If($0, Term(.UnitType), Term(.BooleanType))) })
	}

	func testProductTypechecksToSigmaType() {
		assert(Expression.Product(Term(.Unit), Term(false)).typecheck().right, ==, Expression.lambda(Term(.UnitType), const(Term(.BooleanType))))
	}

	func testDependentProductTypechecksToSigmaType() {
		let type = Expression.lambda(Term(.BooleanType)) { c in Term(.If(c, Term(.UnitType), Term(.BooleanType))) }
		assert(Expression.Annotation(Term(.Product(Term(true), Term(.Unit))), Term(type)).typecheck().right, ==, type)
	}
}

import Assertions
import Manifold
import Prelude
import XCTest

