//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class SubstitutionTests: XCTestCase {
	func testCompositionIsIdempotentIfOperandsAreIdempotent() {
		let (a, b) = (Variable(), Variable())
		let (c, d) = (Variable(), Variable())
		let (t1, t2) = (Type(c), Type(d))
		let s1 = Substitution(elements: [ a: t1 ])
		let s2 = Substitution(elements: [ b: t2 ])
	}
}


// MARK: - Imports

import Manifold
import XCTest
