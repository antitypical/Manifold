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
		let t: Type = .Bool --> .Bool
		assert(t.description, ==, "Bool → Bool")
	}

	func testFunctionTypesParenthesizeParameterFunctions() {
		let t: Type = (.Bool --> .Bool) --> .Bool
		assert(t.description, ==, "(Bool → Bool) → Bool")
	}

	func testFunctionTypesParenthesizeQuantifiedParameterFunctions() {
		let t: Type = Type(forall: [ 0 ], Type(0) --> .Bool) --> .Bool
		assert(t.description, ==, "(∀{α₀}.α₀ → Bool) → Bool")
	}

	func testFunctionTypesDoNotParenthesizeReturnedFunctions() {
		let t: Type = .Bool --> .Bool --> .Bool
		assert(t.description, ==, "Bool → Bool → Bool")
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
