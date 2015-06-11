//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testTrivialHigherOrderConstruction() {
		assert(Value.pi(.type, id).quote, ==, Term.pi(.type, Term.bound(0)))
	}

	func testHigherOrderConstruction() {
		assert(identity, ==, Term.pi(.type, .pi(.bound(0), .bound(0))))
	}

	func testTypechecking() {
		assert(identity.typecheck().right?.quote, ==, Value.pi(.type, const(.pi(.free(0), const(.free(0))))).quote)
	}

	func testPiTypeDescription() {
		assert(identity.typecheck().right?.quote.description, ==, "Π : Type . Π : a . a")
	}

	func testSigmaTypeDescription() {
		assert(Value.sigma(.type, const(.type)).quote.typecheck().right?.quote.description, ==, "Σ Type1 . Type1")
	}

	func testTypeOfType0IsType1() {
		assert(Term.type.typecheck().right?.quote, ==, Term.type(1))
	}

	func testTypeOfAbstractionIsAbstractionType() {
		assert(Value.pi(.type, id).quote.typecheck().right?.quote, ==, Term.pi(.type, .type))
	}


	func testBoundVariablesEvaluateToTheValueBoundInTheEnvironment() {
		assert(Term.bound(2).evaluate(Environment([ .forall(id), .forall(id), .type ])).quote, ==, Term.type)
	}

	func testTrivialAbstractionEvaluatesToItself() {
		let lambda = Value.pi(.type, id).quote
		assert(lambda.evaluate().quote, ==, lambda)
	}

	func testAbstractionEvaluatesToItself() {
		assert(identity.evaluate().quote, ==, identity)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate().quote, ==, Term.type)
	}

	func testApplicationEvaluation() {
		assert(Term.application(Value.pi(.type, id).quote, .type).evaluate().quote, ==, .type)
	}

	func testEvaluation() {
		let value = identity.typecheck().map { Term.application(Term.application(identity, $0.quote), identity).evaluate() }
		assert(value.right?.quote, ==, identity)
		assert(value.left, ==, nil)
	}


	func testGlobalsPrintTheirNames() {
		assert(Term.free("Global").description, ==, "Global")
	}


	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Term.sigma(.type(1), .type(2))
		assert(Term.projection(product, false).typecheck().right?.quote, ==, Term.type(2))
		assert(Term.projection(product, true).typecheck().right?.quote, ==, Term.type(3))
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.sigma(.type(1), .type(2))
		assert(Term.projection(product, false).evaluate().quote, ==, Term.type(1))
		assert(Term.projection(product, true).evaluate().quote, ==, Term.type(2))
	}


	func testConstantFunctionConstruction() {
		assert(constant, ==, Term.pi(.type, .pi(.type, .pi(.bound(1), .pi(.bound(1), .bound(1))))))
	}
}

private let identity = Value.pi(.type) { A in .pi(A, id) }.quote
private let constant = Value.pi(.type) { A in Value.pi(.type) { B in Value.pi(A) { a in Value.pi(B) { b in a } } } }.quote


import Assertions
import Either
import Manifold
import Prelude
import XCTest
