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


	func testFunctionTypesPrintWithArrow() {
		let t: Type = .Bool --> .Bool
		println(t)
	}
}


// MARK: - Imports

import Assertions
import Manifold
import Set
import XCTest
