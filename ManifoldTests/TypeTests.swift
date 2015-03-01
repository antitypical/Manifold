//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class TypeTests: XCTestCase {
	func testVariableTypesHaveOneFreeVariable() {
		let variable = Variable()
		assertEqual(Type(variable).freeVariables, Set([ variable ]))
	}

	func testFunctionTypesDistributeFreeVariables() {
		let variable = Variable()
		assertEqual(Type(function: Type(variable), Type(variable)).freeVariables, Set([ variable ]))
	}

	func testFreeVariablesIncludeTypeFreeVariables() {
		let variable = Variable()
		assertEqual(Type(forall: [], Type(variable)).freeVariables, Set([ variable ]))
	}

	func testFreeVariablesExcludeBoundVariables() {
		let (a, b) = (Variable(), Variable())
		assertEqual(Type(forall: [ a ], Type(function: Type(a), Type(b))).freeVariables, Set([ b ]))
	}


	func testVariableTypesPrintAsSubscriptsOfTau() {
		let t: Type = .Variable(1234567890)
		assert(t.description, ==, "τ₁₂₃₄₅₆₇₈₉₀")
	}

	func testFunctionTypesPrintWithArrow() {
		let t: Type = .Unit --> .Unit
		assert(t.description, ==, "Unit → Unit")
	}

	func testFunctionTypesParenthesizeParameterFunctions() {
		let t: Type = (.Unit --> .Unit) --> .Unit
		assert(t.description, ==, "(Unit → Unit) → Unit")
	}

	func testFunctionTypesParenthesizeQuantifiedParameterFunctions() {
		let t: Type = Type(forall: [ 0 ], Type(0) --> .Unit) --> .Unit
		assert(t.description, ==, "(∀{α₀}.α₀ → Unit) → Unit")
	}

	func testFunctionTypesDoNotParenthesizeReturnedFunctions() {
		let t: Type = .Unit --> .Unit --> .Unit
		assert(t.description, ==, "Unit → Unit → Unit")
	}

	func testUniversalTypesPrintWithQuantifier() {
		let t = Type(forall: [ 1, 2 ], .Variable(1) --> .Variable(2) --> .Variable(3))
		assert(t.description, ==, "∀{α₁,α₂}.α₁ → α₂ → τ₃")
	}
}


// MARK: - Imports

import Assertions
import Manifold
import Set
import XCTest
