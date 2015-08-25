//  Copyright © 2015 Rob Rix. All rights reserved.

final class ExpressionTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.description, ==, "λ b : Type . λ a : b . a")
		assert(identity.out.inferType().right?.description, ==, "λ b : Type . λ a : b . b")
	}

	func testProductDescription() {
		assert(Term.Product(.Unit, .Unit).description, ==, "(() × ())")
	}

	func testProductTypeDescription() {
		assert(Term.Product(.Unit, .Unit).out.inferType().right?.description, ==, "λ a : Unit . Unit")
	}

	func testGlobalsPrintTheirNames() {
		assert(Expression<Term>.Variable("Global").description, ==, "Global")
	}


	func testNullarySumsAreUnitType() {
		assert(Expression<Term>.Sum([]), ==, .UnitType)
	}

	func testUnarySumsAreTheIdentityConstructor() {
		assert(Expression.Sum([ Term.BooleanType ]), ==, .BooleanType)
	}

	func testNArySumsAreProducts() {
		assert(Expression.Sum([ Term.BooleanType, Term.BooleanType ]), ==, Expression.Lambda(0, .BooleanType, .If(0, .BooleanType, .BooleanType)))
	}

	func testHigherOrderConstruction() {
		assert(Term.lambda(.UnitType, id), ==, .Lambda(0, .UnitType, 0))
		assert(identity, ==, .Lambda(1, .Type, .Lambda(0, 1, 0)))
		assert(constant, ==, .Lambda(3, .Type, .Lambda(2, .Type, .Lambda(1, 3, .Lambda(0, 2, 1)))))
	}

	func testFunctionTypeConstruction() {
		let expected = Term.lambda(.Type) { A in .lambda(.FunctionType(A, A), A, const(A)) }
		let actual = Term.Lambda(2, .Type, .Lambda(1, .Lambda(-1, 2, 2), .Lambda(0, 2, 2)))
		assert(expected, ==, actual)
	}

	func testSubstitution() {
		assert(Expression<Term>.Lambda(0, 1, 0).substitute(1, .Unit), ==, .Lambda(0, .Unit, 0))
	}
}


let identity = Term.lambda(.Type) { A in .lambda(A, id) }
let constant = Term.lambda(.Type) { A in Term.lambda(.Type) { B in Term.lambda(A) { a in .lambda(B, const(a)) } } }


import Assertions
@testable import Manifold
import Prelude
import XCTest
