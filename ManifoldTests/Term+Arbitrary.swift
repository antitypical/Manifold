//  Copyright © 2015 Rob Rix. All rights reserved.

final class TermProperties: XCTestCase {
	override class func setUp() {
		sranddev()
	}

	func testEqualityIsReflexive() {
		property("reflexivity of equality") <- forAll { (term: Term) in
			term == term
		}
	}
}


extension Term: Arbitrary {
	public static var arbitrary: Gen<Term> {
		func arbitrary(n: Int) -> Gen<Term> {
			let topLevel: [Gen<Term>] = [
				Gen.pure(Term.UnitType),
				Bool.arbitrary.fmap { $0 ? .Type : .Type(1) },
				Gen.pure(()).bind {
					arbitrary(n).bind { a in arbitrary(n).fmap { b in Term.Application(a, b) } }
				},
				Gen.pure(()).bind {
					arbitrary(n).bind { type in arbitrary(n + 1).fmap { body in Term.Lambda(n + 1, type, body) } }
				},
			]

			let inBinder = [
				Int.arbitrary.suchThat { $0 <= n && $0 >= 0 }.fmap { Term.Variable(.Local($0)) },
			]

			return Gen.oneOf(topLevel + (n >= 0 ? inBinder : []))
		}
		return arbitrary(-1)
	}
}


@testable import Manifold
import SwiftCheck
import XCTest
