//  Copyright © 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.value.description, ==, "λ b : Type . λ a : b . a")
		assert(try? identity.value.elaborateType(identity.type, [:], [:]).annotation.description, ==, "λ a : Type . a → a")
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
		assert(.Type => id, ==, .Lambda(.Local(0), .Type, 0))
		assert(identity.value, ==, .Lambda(.Type, .Lambda(1, 0)))
		assert(constant, ==, .Lambda(.Type, .Lambda(.Type, .Lambda(2, .Lambda(1, 0)))))
	}

	func testChurchEncodedBooleanConstruction() {
		assert(.Type => { A in (A, A) => { a, _ in a } }, ==, .Lambda(.Type, .Lambda(1, .Lambda(1, 0))))
		assert(.Type => { A in (A, A) => { _, b in b } }, ==, .Lambda( .Type, .Lambda(1, .Lambda(1, 0))))
	}

	func testFunctionTypeConstruction() {
		assert(.Type => { A in (A --> A, A) => const(A) }, ==, .Lambda(.Type, .Lambda(.Lambda(0, 0), .Lambda(0, 0))))
	}

	func testSubstitution() {
		assert(Term.Lambda(1, 0).substitute(.Local(1), with: identity.value), ==, .Lambda(identity.value, 0))
	}

	func testFreeVariablesDoNotIncludeThoseBoundByLambdas() {
		assert(Term.Lambda(.Type, 1).freeVariables, ==, [])
	}

	func testLambdasDoNotShadowFreeVariablesInTheirTypes() {
		assert(Term.Lambda(1, 1).freeVariables, ==, [ .Local(1) ])
	}

	func testLambdasBindVariablesDeeply() {
		assert(Term.Lambda(.Type, .Lambda(2, .Lambda(.Type, .Application(2, .Application(1, 0))))).freeVariables, ==, [])
	}
}


let identity: (type: Term, value: Term) = (type: .Type => { A in A --> A }, value: .Type => { A in A => id })
let constant = .Type => { A in .Type => { B in A => { a in B => const(a) } } }


import Assertions
@testable import Manifold
import Prelude
import XCTest
