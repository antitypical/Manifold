//  Copyright © 2015 Rob Rix. All rights reserved.

final class LocationTests: XCTestCase {
	func testTraversingAnExpressionReturnsALocationAtTheTraversedExpression() {
		assert(identity.explore().it, ==, identity)
	}

	func testTopLevelNodesHaveNoParents() {
		assert(Expression<Term>.Unit.explore().up?.it, ==, nil)
	}

	func testTopLevelNodesHaveNoSiblings() {
		assert(Expression<Term>.Unit.explore().left?.it, ==, nil)
		assert(Expression<Term>.Unit.explore().right?.it, ==, nil)
	}

	func testNullaryNodesHaveNoChildren() {
		assert(Expression<Term>.Unit.explore().down?.it, ==, nil)
	}

	func testDeepNavigationExploresChildrenOfChildrenRecursively() {
		assert(identity.explore().down?.right?.down?.right?.it, ==, .Variable(.Local(0)))
	}
}


import Assertions
@testable import Manifold
import XCTest
