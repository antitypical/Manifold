//  Copyright © 2015 Rob Rix. All rights reserved.

final class TermTests: XCTestCase {
	func testLambdaTypeDescription() {
		assert(identity.description, ==, "λ b : Type . λ a : b . a")
		assert(identity.inferType().right?.description, ==, "λ a : Type . a → a")
	}

	func testProductDescription() {
		assert(Term.Product(.Unit, .Unit).description, ==, "() × ()")
	}

	func testFunctionTypeDescription() {
		assert(Term.FunctionType(.UnitType, .UnitType).description, ==, "Unit → Unit")
	}

	func testGlobalsPrintTheirNames() {
		assert(Term.Variable("Global").description, ==, "Global")
	}


	func testHigherOrderConstruction() {
		assert(Term.lambda(.UnitType, id), ==, .Lambda(0, .UnitType, 0))
		assert(identity, ==, .Lambda(1, .Type, .Lambda(0, 1, 0)))
		assert(constant, ==, .Lambda(2, .Type, .Lambda(1, .Type, .Lambda(0, 2, .Lambda(-1, 1, 0)))))
	}

	func testChurchEncodedBooleanConstruction() {
		assert(Term.lambda(.Type) { A in Term.lambda(A, A) { a, _ in a } }, ==, .Lambda(1, .Type, .Lambda(0, 1, .Lambda(-1, 1, 0))))
		assert(Term.lambda(.Type) { A in Term.lambda(A, A) { _, b in b } }, ==, .Lambda(1, .Type, .Lambda(-1, 1, .Lambda(0, 1, 0))))
	}

	func testFunctionTypeConstruction() {
		assert(Term.lambda(.Type) { A in .lambda(.FunctionType(A, A), A, const(A)) }, ==, .Lambda(0, .Type, .Lambda(-1, .Lambda(-1, 0, 0), .Lambda(-1, 0, 0))))
	}

	func testSubstitution() {
		assert(Term.Lambda(0, 1, 0).substitute(1, .Unit), ==, .Lambda(0, .Unit, 0))
	}

	func testFreeVariablesDoNotIncludeThoseBoundByLambdas() {
		assert(Term.Lambda(1, .UnitType, 1).freeVariables, ==, [])
	}

	func testLambdasDoNotShadowFreeVariablesInTheirTypes() {
		assert(Term.Lambda(1, 1, 1).freeVariables, ==, [ 1 ])
	}

	func testLambdasBindVariablesDeeply() {
		assert(Term.Lambda(2, .Type, .Lambda(1, 2, .Lambda(0, .UnitType, .Product(2, .Product(1, 0))))).freeVariables, ==, [])
	}
}


let identity = Term.lambda(.Type) { A in .lambda(A, id) }
let constant = Term.lambda(.Type) { A in Term.lambda(.Type) { B in Term.lambda(A) { a in .lambda(B, const(a)) } } }


import Assertions
@testable import Manifold
import Prelude
import XCTest
