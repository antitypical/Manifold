//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testTrivialHigherOrderConstruction() {
		assert(Value.pi(.Type, id).quote, ==, Term(.Pi(Box(.type), Box(Term(.Bound(0))))))
	}

	func testHigherOrderConstruction() {
		let expected = Term(.Pi(Box(.type), Box(Term(.Pi(Box(Term(.Bound(0))), Box(Term(.Bound(1))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right?.quote, ==, Value.pi(.Type, const(.pi(.Type, const(.Type)))).quote)
	}

	func testFunctionTypesArePrintedWithAnArrow() {
		assert(identity.typecheck().right?.quote.description, ==, "(Type) → (Type) → Type")
	}

	func testProductTypesArePrintedWithAnX() {
		assert(Value.sigma(.Type, const(.Type)).quote.typecheck().right?.quote.description, ==, "(Type ✕ Type)")
	}

	func testTypeOfTypeIsType() {
		assert(Term.type.typecheck().right?.quote, ==, Term.type)
	}

	func testTypeOfAbstractionIsAbstractionType() {
		assert(Value.pi(.Type, id).quote.typecheck().right?.quote, ==, Term(.Pi(Box(.type), Box(.type))))
	}


	func testBoundVariablesEvaluateToTheValueBoundInTheEnvironment() {
		assert(Term(.Bound(2)).evaluate([ .forall(id), .forall(id), .Type ]).right?.quote, ==, Term.type)
	}

	func testTrivialAbstractionEvaluatesToItself() {
		let lambda = Value.pi(.Type, id).quote
		assert(lambda.evaluate().right?.quote, ==, lambda)
	}

	func testAbstractionEvaluatesToItself() {
		assert(identity.evaluate().right?.quote, ==, identity)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate().right?.quote, ==, Term.type)
	}

	func testApplicationEvaluation() {
		assert(Term.application(Value.pi(.Type, id).quote, .type).evaluate().right?.quote, ==, .type)
	}

	func testEvaluation() {
		let value = identity.typecheck().flatMap { Term.application(Term.application(identity, $0.quote), identity).evaluate() }
		assert(value.right?.quote, ==, identity)
		assert(value.left, ==, nil)
	}


	func testGlobalsPrintTheirNames() {
		assert(Term(.Free("Global")).description, ==, "Global")
	}
}


private let identity = Value.pi(.Type) { A in .pi(A, id) }.quote
private let constant = Value.pi(.Type) { A in Value.pi(.Type) { B in Value.pi(A) { a in Value.pi(B) { b in a } } } }.quote


import Assertions
import Box
import Either
import Manifold
import Prelude
import XCTest
