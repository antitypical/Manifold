//  Copyright © 2015 Rob Rix. All rights reserved.

final class LocationTests: XCTestCase {
	func testTraversingAnExpressionReturnsALocationAtTheTraversedExpression() {
		assert(identity.explore().it, ==, identity)
	}

	func testRootNodesHaveNoParents() {
		assert(Expression<Term>.Unit.explore().up?.it, ==, nil)
	}

	func testRootNodesHaveNoSiblings() {
		assert(Expression<Term>.Unit.explore().left?.it, ==, nil)
		assert(Expression<Term>.Unit.explore().right?.it, ==, nil)
	}

	func testNullaryNodesHaveNoChildren() {
		assert(Expression<Term>.Unit.explore().down?.it, ==, nil)
	}

	func testNullaryNodesCanBeReturnedOutOf() {
		let axiom = Expression.Axiom((), Term(.UnitType))
		assert(axiom.explore().down?.up?.it, ==, axiom)
	}

	func testDeepNavigationExploresChildrenOfChildrenRecursively() {
		assert(identity.explore().down?.right?.down?.right?.it, ==, .Variable(.Local(0)))
	}

	func testDeepNavigationReturnsUpwards() {
		assert(identity.explore().down?.right?.down?.right?.up?.up?.it, ==, identity)
	}

	func testModifyReplacesSubtrees() {
		assert(identity.explore().down?.modify(const(.BooleanType)).right?.modify(const(.Boolean(true))).up?.it, ==, Expression.Lambda(1, Term(.BooleanType), Term(.Boolean(true))))
	}
}


import Assertions
@testable import Manifold
import Prelude
import XCTest
