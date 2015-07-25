//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
	func testListTypechecksAsAHigherOrderType() {
		let kind = Expression<Term>.Variable("List").typecheck(context)
		assert(kind.left, ==, nil)
		assert(kind.right, ==, Expression<Term>.lambda(.Type(0), const(.Type(0))))
	}

	func testEmptyListEliminatesWithSecondArgumentToUncons() {
		let eliminated = uncons[Term(.UnitType), Term(.BooleanType), Term.lambda(Term(.UnitType), const(Term.lambda(List[Term(.UnitType)], const(Term(false))))), Term.lambda(Term(.UnitType), const(Term(true))), empty]
		assert(eliminated.out.evaluate(environment), ==, true)
	}

	func testNonEmptyListsEliminateWithFirstArgumentToUncons() {
		let eliminated = uncons[Term(.UnitType), Term(.BooleanType), Term.lambda(Term(.UnitType), const(Term.lambda(List[Term(.UnitType)], const(Term(true))))), Term.lambda(Term(.UnitType), const(Term(false))), unary]
		assert(eliminated.out.evaluate(environment), ==, true)
	}
}


private let context = Expression<Term>.list.context
private let environment = Expression<Term>.list.environment

private let List = Term("List")
private let cons = Term("::")
private let uncons = Term("uncons")
private let empty = Term("[]")[Term(.UnitType)]
private let unary = cons[Term(.UnitType), Term(.Unit), empty]


import Assertions
@testable import Manifold
import Prelude
import XCTest
