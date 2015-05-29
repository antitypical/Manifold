//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testTrivialHigherOrderConstruction() {
		assert(Value.pi(.type, id).quote, ==, Term(.Pi(Box(.type), Box(Term(.Bound(0))))))
	}

	func testHigherOrderConstruction() {
		let expected = Term(.Pi(Box(.type), Box(Term(.Pi(Box(Term(.Bound(0))), Box(Term(.Bound(0))))))))
		assert(identity, ==, expected)
	}

	func testTypechecking() {
		assert(identity.typecheck().right?.quote, ==, Value.pi(.type, const(.pi(.free(0), const(.free(0))))).quote)
	}

	func testPiTypeDescription() {
		assert(identity.typecheck().right?.quote.description, ==, "Π : Type . Π : a . a")
	}

	func testSigmaTypeDescription() {
		assert(Value.sigma(.type, const(.type)).quote.typecheck().right?.quote.description, ==, "Σ Type . Type")
	}

	func testTypeOfTypeIsType() {
		assert(Term.type.typecheck().right?.quote, ==, Term.type)
	}

	func testTypeOfAbstractionIsAbstractionType() {
		assert(Value.pi(.type, id).quote.typecheck().right?.quote, ==, Term(.Pi(Box(.type), Box(.type))))
	}


	func testBoundVariablesEvaluateToTheValueBoundInTheEnvironment() {
		assert(Term(.Bound(2)).evaluate(Environment([ .forall(id), .forall(id), .type ])).quote, ==, Term.type)
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
		assert(Term(.Free("Global")).description, ==, "Global")
	}
}

extension Name: Arbitrary {
	public static func arbitrary() -> Gen<Name> {
		return Gen.oneOf([
			String.arbitrary().fmap(Name.global),
			Int.arbitrary().fmap(Name.local),
		])
	}

	public static func shrink(name: Name) -> [Name] {
		return name.analysis(
			ifGlobal: { String.shrink($0).map(Name.global) },
			ifLocal: { Int.shrink($0).map(Name.local) },
			ifQuote: const(shrinkNone(name)))
	}
}


private let identity = Value.pi(.type) { A in .pi(A, id) }.quote
private let constant = Value.pi(.type) { A in Value.pi(.type) { B in Value.pi(A) { a in Value.pi(B) { b in a } } } }.quote


import Assertions
import Box
import Either
import Manifold
import Prelude
import SwiftCheck
import XCTest
