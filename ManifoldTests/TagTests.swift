//  Copyright © 2015 Rob Rix. All rights reserved.

final class TagTests: XCTestCase {
	func testEmptyEnumerationYieldsEmptyTag() {
		assert(Tag.tags([]), ==, [])
	}

	func testFirstLabelMapsToHere() {
		assert(Tag.tags([ "unit" ]), ==, [ Tag.Here("unit", []) ])
	}

	func testLaterLabelsMapToThere() {
		assert(Tag.tags([ "true", "false" ]), ==, [ Tag.Here("true", [ "false" ]), Tag.There("true", Tag.Here("false", [])) ])
	}

	func testNLabelsMapToNTags() {
		assert(Tag.tags([ "a", "b", "c" ]), ==, [
			Tag.Here("a", [ "b", "c" ]),
			Tag.There("a", Tag.Here("b", [ "c" ])),
			Tag.There("a", Tag.There("b", Tag.Here("c", []))),
		])
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
