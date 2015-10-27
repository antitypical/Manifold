//  Copyright © 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.value.description, ==, "λ b : Type . λ a : b . a")
		assert(try? identity.value.elaborateType(identity.type, [:], [:]).type.description, ==, "λ a : Type . a → a")
	}

	func testRightNestedFunctionTypesAreNotParenthesized() {
		assert((Term(.Type(0)) --> .Type).description, ==, "Type → Type")
		assert((Term(.Type(0)) --> .Type --> .Type).description, ==, "Type → Type → Type")
	}

	func testLeftNestedFunctionTypesAreParenthesized() {
		assert(((Term(.Type(0)) --> .Type) --> .Type).description, ==, "(Type → Type) → Type")
	}

	func testGlobalsPrintTheirNames() {
		assert(Term.Variable("Global").description, ==, "Global")
	}


	func testHigherOrderConstruction() {
		assert(.Type => id, ==, .Lambda(0, .Type, 0))
		assert(identity.value, ==, .Lambda(1, .Type, .Lambda(0, 1, 0)))
		assert(constant, ==, .Lambda(2, .Type, .Lambda(1, .Type, .Lambda(0, 2, .Lambda(-1, 1, 0)))))
	}

	func testChurchEncodedBooleanConstruction() {
		assert(.Type => { A in (A, A) => { a, _ in a } }, ==, .Lambda(1, .Type, .Lambda(0, 1, .Lambda(-1, 1, 0))))
		assert(.Type => { A in (A, A) => { _, b in b } }, ==, .Lambda(1, .Type, .Lambda(-1, 1, .Lambda(0, 1, 0))))
	}

	func testFunctionTypeConstruction() {
		assert(.Type => { A in (A --> A, A) => const(A) }, ==, .Lambda(0, .Type, .Lambda(-1, .Lambda(-1, 0, 0), .Lambda(-1, 0, 0))))
	}

	func testSubstitution() {
		assert(Term.Lambda(0, 1, 0).substitute(1, identity.value), ==, .Lambda(0, identity.value, 0))
	}

	func testFreeVariablesDoNotIncludeThoseBoundByLambdas() {
		assert(Term.Lambda(1, .Type, 1).freeVariables, ==, [])
	}

	func testLambdasDoNotShadowFreeVariablesInTheirTypes() {
		assert(Term.Lambda(1, 1, 1).freeVariables, ==, [ 1 ])
	}

	func testLambdasBindVariablesDeeply() {
		assert(Term.Lambda(2, .Type, .Lambda(1, 2, .Lambda(0, .Type, .Application(2, .Application(1, 0))))).freeVariables, ==, [])
	}
}


let identity: (type: Term, value: Term) = (type: .Type => { A in A --> A }, value: .Type => { A in A => id })
let constant = .Type => { A in .Type => { B in A => { a in B => const(a) } } }


import Assertions
@testable import Manifold
import Prelude
import XCTest
