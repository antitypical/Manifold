//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType([ Enumeration, Term(.Type(0)) ])
		let actual = Tag.out.checkType(expected, context: context)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}

	func testBranchesProducesAType() {
		let branches = Branches[Empty, Term(.lambda(Tag[Empty], const(Term(.UnitType))))].out.checkType(.Type(0), context: context)
		assert(branches.left, ==, nil)
		assert(branches.right, ==, .Type(0))
	}

	func testBranchesOfEmptyEnumerationIsUnitType() {
		assert(Branches[Empty, Term(.lambda(Tag[Empty], const(Term(.BooleanType))))].out.evaluate(environment), ==, .UnitType)
	}
}

private let Enumeration = Term("Enumeration")
private let Branches = Term("Branches")
private let `nil` = Term("[]")
private let Tag = Term("Tag")
private let Empty = `nil`[Term("String")]

private let module = Expression<Term>.tag
private let context = module.context
private let environment = module.environment


import Assertions
@testable import Manifold
import Prelude
import XCTest
