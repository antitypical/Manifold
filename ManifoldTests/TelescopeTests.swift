//  Copyright © 2015 Rob Rix. All rights reserved.

final class TelescopeTests: XCTestCase {
	// MARK: Types

	func testEmptyDataConstructorHasUnitType() {
		assert(Telescope.End.type("A"), ==, .UnitType)
	}

	func testRecursiveDataConstructorHasFunctionType() {
		assert(Telescope.Recursive(.End).type("A"), ==, .lambda("A", const(.UnitType)))
	}

	func testMultiplyRecursiveDataConstructorHasFunctionType() {
		assert(Telescope.Recursive(.Recursive(.End)).type("A"), ==, .lambda("A", const(.lambda("A", const(.UnitType)))))
	}

	func testArgumentDataConstructorHasFunctionType() {
		assert(Telescope.Argument("B", const(.Recursive(.End))).type("A"), ==, .lambda("B", const(.lambda("A", const(.UnitType)))))
	}


	// MARK: Values

	func testEmptyDataConstructorHasUnitValue() {
		assert(Telescope.End.value("A"), ==, .Unit)
	}

	func testRecursiveDataConstructorHasLambdaValueReturningProductValue() {
		assert(Telescope.Recursive(.End).value("A"), ==, .lambda("A", { .Product($0, .Unit) }))
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
