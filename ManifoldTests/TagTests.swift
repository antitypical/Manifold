//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testEmptyEnumerationYieldsEmptyTag() {
		assert(Manifold.Tag.tags([]), ==, [])
	}

	func testFirstLabelMapsToHere() {
		assert(Manifold.Tag.tags([ "unit" ]), ==, [ Manifold.Tag.Here("unit", []) ])
	}

	func testLaterLabelsMapToThere() {
		assert(Manifold.Tag.tags([ "true", "false" ]), ==, [ Manifold.Tag.Here("true", [ "false" ]), Manifold.Tag.There("true", Manifold.Tag.Here("false", [])) ])
	}

	func testNLabelsMapToNTags() {
		assert(Manifold.Tag.tags([ "a", "b", "c" ]), ==, [
			Manifold.Tag.Here("a", [ "b", "c" ]),
			Manifold.Tag.There("a", Manifold.Tag.Here("b", [ "c" ])),
			Manifold.Tag.There("a", Manifold.Tag.There("b", Manifold.Tag.Here("c", []))),
		])
	}

	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType(Enumeration, Term(.Type(0)))
		let actual = Tag.out.checkType(expected, environment, context)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}

	func testBranchesProducesAType() {
		let branches = Branches[Empty, Term(.lambda(Tag[Empty], const(Term(.UnitType))))].out.checkType(.Type(0), environment, context)
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
