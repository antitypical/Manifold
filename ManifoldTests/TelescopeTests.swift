//  Copyright © 2015 Rob Rix. All rights reserved.

final class TelescopeTests: XCTestCase {
	// MARK: Types

	func testEmptyDataConstructorHasUnitType() {
		assert(Telescope<Term>.End.type("A"), ==, "A")
	}

	func testRecursiveDataConstructorHasFunctionType() {
		assert(Telescope<Term>.Recursive(.End).type("A"), ==, .lambda("A", const("A")))
	}

	func testMultiplyRecursiveDataConstructorHasFunctionType() {
		assert(Telescope<Term>.Recursive(.Recursive(.End)).type("A"), ==, .lambda("A", const(.lambda("A", const("A")))))
	}

	func testArgumentDataConstructorHasFunctionType() {
		assert(Telescope<Term>.Argument("B", const(.Recursive(.End))).type("A"), ==, .lambda("B", const(.lambda("A", const("A")))))
	}


	// MARK: Values

	func testEmptyDataConstructorHasUnitValue() {
		assert(Telescope<Term>.End.value("A"), ==, .Unit)
	}

	func testRecursiveDataConstructorHasLambdaValueReturningProductValue() {
		assert(Telescope<Term>.Recursive(.End).value("A"), ==, .lambda("A", id))
	}

	func testMultiplyRecursiveDataConstructorHasLambdaValueReturningProductValue() {
		assert(Telescope<Term>.Recursive(.Recursive(.End)).value("A"), ==, .lambda("A", "A", Term.Product))
	}

	func testArgumentDataConstructorHasLambdaValueReturningProductValue() {
		assert(Telescope<Term>.Argument("B", const(.Recursive(.End))).value("A"), ==, .lambda("B", "A", Term.Product))
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
