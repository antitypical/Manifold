//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType([ Enumeration, Term(.Type(0)) ])
		let actual = Tag.out.typecheck(context, against: expected)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}

	func testBranchesProducesAType() {
		assert(Branches[Empty, Term(.lambda(Tag[Empty], const(Term(.UnitType))))].out.typecheck(context, against: .Type(0)).right, ==, .Type(0))
	}
}

private let Enumeration = Term("Enumeration")
private let Branches = Term("Branches")
private let `nil` = Term("[]")
private let Tag = Term("Tag")
private let Empty = `nil`[Term("String")]

private let context = Expression<Term>.tag.context


import Assertions
@testable import Manifold
import Prelude
import XCTest
