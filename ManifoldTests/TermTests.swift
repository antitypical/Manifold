//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testHigherOrderConstruction() {
		let expected = Term(.Pi(0, Box(.type), Box(Term(.Pi(1, Box(Term(.Bound(0))), Box(Term(.Bound(1))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right?.quote, ==, .lambda(.type, const(.lambda(.type, const(.type)))))
	}

	func testFunctionTypesArePrintedWithAnArrow() {
		assert(identity.typecheck().right?.quote.description, ==, "(Type) → (Type) → Type")
	}

	func testProductTypesArePrintedWithAnX() {
		assert(Term.pair(.type, const(.type)).typecheck().right?.quote.description, ==, "(Type ✕ Type)")
	}


	func testBoundVariablesEvaluateToTheValueBoundInTheEnvironment() {
		assert(Term(.Bound(2)).evaluate([ 2: .Type ])?.quote, ==, Term.type)
	}

	func testTrivialAbstractionEvaluatesToItself() {
		let lambda = Term.lambda(.type, id)
		assert(lambda.evaluate()?.quote, ==, lambda)
	}

	func testAbstractionEvaluatesToItself() {
		assert(identity.evaluate()?.quote, ==, identity)
	}

	func testTypeEvaluatesToItself() {
		assert(Term.type.evaluate()?.quote, ==, Term.type)
	}

	func testApplicationEvaluation() {
		assert(Term.application(Term.lambda(.type, id), .type).evaluate()?.quote, ==, .type)
	}

	func testEvaluation() {
		let value = identity.typecheck().flatMap {
			Term.application(Term.application(identity, $0.quote), identity).evaluate().map(Either.right)
				?? Either.left("evaluation returned nil for some reason")
		}
		assert(value.right?.quote, ==, identity)
		assert(value.left, ==, nil)
	}
}


private let identity = Term.lambda(.type) { A in .lambda(A, id) }


import Assertions
import Box
import Either
import Manifold
import Prelude
import XCTest
