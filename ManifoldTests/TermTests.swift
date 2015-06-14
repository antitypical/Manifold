//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testTypechecking() {
		assert(identity.typecheck().right, ==, Term.pi(.type, .pi(.free(0), .free(0))))
	}

	func testPiTypeDescription() {
		assert(identity.typecheck().right?.description, ==, "Π : Type . Π : a . a")
	}

	func testSigmaTypeDescription() {
		assert(Term.sigma(.type, .type).typecheck().right?.description, ==, "Σ Type1 . Type1")
	}

	func testTypeOfType0IsType1() {
		assert(Term.type.typecheck().right, ==, Term.type(1))
	}

	func testTypeOfAbstractionIsAbstractionType() {
		assert(Term.pi(.type, .bound(0)).typecheck().right, ==, Term.pi(.type, .type))
	}


	func testBoundVariablesEvaluateToTheValueBoundInTheEnvironment() {
		assert(Term.bound(2).evaluate(Environment([ .pi(.type, .bound(0)), .pi(.type, .bound(0)), .type ])), ==, Term.type)
	}

	func testTrivialAbstractionEvaluatesToItself() {
		let lambda = Term.pi(.type, .bound(0))
		assert(lambda.evaluate(), ==, lambda)
	}

	func testAbstractionEvaluatesToItself() {
		assert(identity.evaluate(), ==, identity)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate(), ==, Term.type)
	}

	func testApplicationEvaluation() {
		assert(Term.application(Term.pi(.type, .bound(0)), .type).evaluate(), ==, .type)
	}

	func testEvaluation() {
		let value = identity.typecheck().map { Term.application(Term.application(identity, $0), identity).evaluate() }
		assert(value.right, ==, identity)
		assert(value.left, ==, nil)
	}


	func testGlobalsPrintTheirNames() {
		assert(Term.free("Global").description, ==, "Global")
	}


	func testProjectionTypechecksToTypeOfProjectedField() {
		let product = Term.sigma(.type(1), .type(2))
		assert(Term.projection(product, false).typecheck().right, ==, Term.type(2))
		assert(Term.projection(product, true).typecheck().right, ==, Term.type(3))
	}

	func testProjectionEvaluatesToProjectedField() {
		let product = Term.sigma(.type(1), .type(2))
		assert(Term.projection(product, false).evaluate(), ==, Term.type(1))
		assert(Term.projection(product, true).evaluate(), ==, Term.type(2))
	}
}

private let identity = Term.pi(.type, .pi(.bound(0), .bound(0)))
private let constant = Term.pi(.type, .pi(.type, .pi(.bound(1), .pi(.bound(1), .bound(1)))))


import Assertions
import Manifold
import Prelude
import XCTest
