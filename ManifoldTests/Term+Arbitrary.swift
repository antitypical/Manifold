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
			let type: [Gen<Term>] = [
				Bool.arbitrary.fmap { $0 ? .Type : .Type(1) },
			]
			let lambdas = [
				Gen.pure(()).bind {
					arbitrary(n + 1).bind { a in arbitrary(n + 1).fmap { b in Term.Application(a, b) } }
				},
				Gen.pure(()).bind {
					arbitrary(n + 1).bind { type in arbitrary(n + 1).fmap { body in Term.Lambda(n + 1, type, body) } }
				},
			]
			let variable = [
				Int.arbitrary.suchThat { $0 <= n && $0 >= 0 }.fmap { Term.Variable(.Local($0)) },
			]

			return Gen.oneOf(type + (n <= 7 ? lambdas : []) + (n >= 0 ? variable : []))
		}
		return arbitrary(-1)
	}
}


@testable import Manifold
import SwiftCheck
import XCTest
