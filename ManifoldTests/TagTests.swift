//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testConstructsOneTagPerLabel() {
		assert(Tag.tags([ "a", "b", "c" ]).count, ==, 3)
	}

	func testConstructsTagsInOrder() {
		let tags = Tag.tags([ "a", "b", "c" ])
		assert(tags[0], ==, Tag.Here("a", ["b", "c"]))
		assert(tags[1], ==, Tag.There("a", ["b", "c"], { Tag.Here("b", ["c"]) }))
		assert(tags[2], ==, Tag.There("a", ["b", "c"], { Tag.There("b", ["c"], { Tag.Here("c", []) }) }))
	}

	func testTagTypechecksAsFunction() {
		let expected = Expression.FunctionType([ Term("Enumeration"), Term(.Type(0)) ])
		let actual = Term("Tag").out.typecheck(Expression<Term>.tag.context, against: expected)
		assert(actual.left, ==, nil)
		assert(actual.right, ==, expected)
	}
}


import Assertions
@testable import Manifold
import XCTest
