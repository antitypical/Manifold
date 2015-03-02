//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SubstitutionTests: XCTestCase {
	let (a, b) = (Variable(), Variable())
	let (c, d) = (Variable(), Variable())
	var t1: Term { return Term(c) }
	var t2: Term { return Term(function: Term(d), Term(d)) }

	func testCompositionIsIdempotentIfOperandsAreIdempotent() {
		let s1: Substitution = [ a: t1 ]
		let s2: Substitution = [ b: t2 ]
		assertEqual(s1.compose(s2).occurringVariables, Set())
		assertEqual(s2.compose(s1).occurringVariables, Set())
	}

	func testCompositionIsNotIdempotentIfLeftOperandIsNotIdempotent() {
		let s1: Substitution = [ a: Term(a) ]
		let s2: Substitution = [ b: t2 ]
		assertEqual(s1.compose(s2).occurringVariables, Set([ a ]))
	}

	func testCompositionIsNotIdempotentIfRightOperandIsNotIdempotent() {
		let s1: Substitution = [ a: t1 ]
		let s2: Substitution = [ b: Term(b) ]
		assertEqual(s1.compose(s2).occurringVariables, Set([ b ]))
	}

	func testCompositionIsNotCommutative() {
		let s1: Substitution = [ a: t1 ]
		let s2: Substitution = [ a: t2 ]
		XCTAssertNotEqual(s1.compose(s2), s2.compose(s1))
	}

	func testEmptySubstitutionIsTheIdentitySubstitution() {
		let s: Substitution = [:]
		assertEqual(s.apply(t1), t1)
		assertEqual(s.apply(t2), t2)
	}
}


// MARK: - Imports

import Assertions
import Manifold
import Set
import XCTest
