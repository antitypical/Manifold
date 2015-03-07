//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testVariableTypesHaveOneFreeVariable() {
		let variable = Variable()
		assertEqual(Term(variable).freeVariables, Set([ variable ]))
	}

	func testFunctionTypesDistributeFreeVariables() {
		let variable = Variable()
		assertEqual(Term.function(Term(variable), Term(variable)).freeVariables, Set([ variable ]))
	}

	func testFreeVariablesIncludeTypeFreeVariables() {
		let variable = Variable()
		assertEqual(Term(forall: [], Term(variable)).freeVariables, Set([ variable ]))
	}

	func testFreeVariablesExcludeBoundVariables() {
		let (a, b) = (Variable(), Variable())
		assertEqual(Term(forall: [ a ], Term.function(Term(a), Term(b))).freeVariables, Set([ b ]))
	}


	func testVariableTypesPrintAsSubscriptsOfTau() {
		let t = Term(1234567890)
		assert(t.description, ==, "τ₁₂₃₄₅₆₇₈₉₀")
	}

	func testFunctionTypesPrintWithArrow() {
		let t: Term = .Unit --> .Unit
		assert(t.description, ==, "Unit → Unit")
	}

	func testFunctionTypesParenthesizeParameterFunctions() {
		let t: Term = (.Unit --> .Unit) --> .Unit
		assert(t.description, ==, "(Unit → Unit) → Unit")
	}

	func testFunctionTypesParenthesizeQuantifiedParameterFunctions() {
		let t: Term = Term(forall: [ 0 ], Term(0) --> .Unit) --> .Unit
		assert(t.description, ==, "(∀{α₀}.α₀ → Unit) → Unit")
	}

	func testFunctionTypesDoNotParenthesizeReturnedFunctions() {
		let t: Term = .Unit --> .Unit --> .Unit
		assert(t.description, ==, "Unit → Unit → Unit")
	}

	func testUniversalTypesPrintWithQuantifier() {
		let t = Term(forall: [ 1, 2 ], Term(1) --> Term(2) --> Term(3))
		assert(t.description, ==, "∀{α₁,α₂}.α₁ → α₂ → τ₃")
	}
}


// MARK: - Imports

import Assertions
import Manifold
import Set
import XCTest
