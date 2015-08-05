//  Copyright © 2015 Rob Rix. All rights reserved.

final class ExpressionTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.description, ==, "λ b : Type . λ a : b . a")
		assert(identity.inferType().right?.description, ==, "λ b : Type . λ a : b . b")
	}

	func testProductDescription() {
		assert(Expression.Product(Term(.Unit), Term(.Unit)).description, ==, "(() × ())")
	}

	func testProductTypeDescription() {
		assert(Expression.Product(Term(.Unit), Term(.Unit)).inferType().right?.description, ==, "λ a : Unit . Unit")
	}

	func testGlobalsPrintTheirNames() {
		assert(Expression<Term>.Variable("Global").description, ==, "Global")
	}


	func testNullarySumsAreUnitType() {
		assert(Expression<Term>.Sum([]), ==, .UnitType)
	}

	func testUnarySumsAreTheIdentityConstructor() {
		assert(Expression.Sum([ Term(.BooleanType) ]), ==, .BooleanType)
	}

	func testNArySumsAreProducts() {
		assert(Expression.Sum([ Term(.BooleanType), Term(.BooleanType) ]), ==, Expression.Lambda(0, Term(.BooleanType), Term(.If(Term(0), Term(.BooleanType), Term(.BooleanType)))))
	}

	func testHigherOrderConstruction() {
		assert(Expression.lambda(Term(.UnitType), id), ==, .Lambda(0, Term(.UnitType), Term(0)))
		assert(identity, ==, .Lambda(1, Term(.Type(0)), Term(.Lambda(0, Term(1), Term(0)))))
		assert(constant, ==, .Lambda(3, Term(.Type(0)), Term(.Lambda(2, Term(.Type(0)), Term(.Lambda(1, Term(3), Term(.Lambda(0, Term(2), Term(1)))))))))
	}

	func testFunctionTypeConstruction() {
		let expected = Expression.lambda(Term(.Type(0))) { A in Term(.lambda(Term(.FunctionType(A, A)), A, const(A))) }
		let actual = Expression.Lambda(2, Term(.Type(0)), Term(.Lambda(1, Term(.Lambda(-1, Term(.Variable(2)), Term(.Variable(2)))), Term(.Lambda(0, Term(.Variable(2)), Term(.Variable(2)))))))
		assert(expected, ==, actual)
	}

	func testSubstitution() {
		assert(Expression.Lambda(0, Term(1), Term(0)).substitute(1, .Unit), ==, .Lambda(0, Term(.Unit), Term(0)))
	}
}


let identity = Expression.lambda(Term(.Type(0))) { A in Term(.lambda(A, id)) }
let constant = Expression.lambda(Term(.Type(0))) { A in Term(Expression.lambda(Term(.Type(0))) { B in Term(Expression.lambda(A) { a in Term(Expression.lambda(B, const(a))) }) }) }


import Assertions
@testable import Manifold
import Prelude
import XCTest
