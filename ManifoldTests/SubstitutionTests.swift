//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SubstitutionTests: XCTestCase {
	let (a, b) = (Variable(), Variable())
	let (c, d) = (Variable(), Variable())
	var t1: Type { return Type(c) }
	var t2: Type { return Type(d) }

	func testCompositionIsIdempotentIfOperandsAreIdempotent() {
		let s1 = Substitution(elements: [ a: t1 ])
		let s2 = Substitution(elements: [ b: t2 ])
		assertEqual(s1.compose(s2).occurringVariables, Set())
		assertEqual(s2.compose(s1).occurringVariables, Set())
	}
}


// MARK: - Imports

import Manifold
import Set
import XCTest
