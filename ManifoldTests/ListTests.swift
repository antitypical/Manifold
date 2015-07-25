//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testListTypechecksAsAHigherOrderType() {
		let kind = Expression<Term>.Variable("List").typecheck(context)
		assert(kind.left, ==, nil)
		assert(kind.right, ==, Expression<Term>.lambda(.Type(0), const(.Type(0))))
	}

	func testEmptyListEliminatesWithSecondArgumentToUncons() {
		let UnitType = Term(.UnitType)
		let BooleanType = Term(.BooleanType)
		let f = Term(false)
		let t = Term(true)
		let eliminated = uncons[UnitType, BooleanType, Term.lambda(UnitType, const(Term.lambda(List[UnitType], const(f)))), Term.lambda(UnitType, const(t)), empty]
		assert(eliminated.out.evaluate(environment), ==, t.out)
	}
}


private let context = Expression<Term>.list.context
private let environment = Expression<Term>.list.environment

private let List = Term("List")
private let uncons = Term("uncons")
private let empty = Term("[]")


import Assertions
@testable import Manifold
import Prelude
import XCTest
