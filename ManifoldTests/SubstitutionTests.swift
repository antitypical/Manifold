//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SubstitutionTests: XCTestCase {
	let (a, b) = (Variable(), Variable())
	let (c, d) = (Variable(), Variable())
	var t1: Type { return Type(c) }
	var t2: Type { return Type(function: Type(d), Type(d)) }

	func testCompositionIsIdempotentIfOperandsAreIdempotent() {
		let s1 = Substitution(elements: [ a: t1 ])
		let s2 = Substitution(elements: [ b: t2 ])
		assertEqual(s1.compose(s2).occurringVariables, Set())
		assertEqual(s2.compose(s1).occurringVariables, Set())
	}

	func testCompositionIsNotIdempotentIfLeftOperandIsNotIdempotent() {
		let s1 = Substitution(elements: [ a: Type(a) ])
		let s2 = Substitution(elements: [ b: t2 ])
		assertEqual(s1.compose(s2).occurringVariables, Set(a))
	}

	func testCompositionIsNotIdempotentIfRightOperandIsNotIdempotent() {
		let s1 = Substitution(elements: [ a: t1 ])
		let s2 = Substitution(elements: [ b: Type(b) ])
		assertEqual(s1.compose(s2).occurringVariables, Set(b))
	}

	func testCompositionIsNotCommutative() {
		let s1 = Substitution(elements: [ a: t1 ])
		let s2 = Substitution(elements: [ a: t2 ])
		XCTAssertNotEqual(s1.compose(s2), s2.compose(s1))
	}
}


// MARK: - Imports

import Manifold
import Set
import XCTest
