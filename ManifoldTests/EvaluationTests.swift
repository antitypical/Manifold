//  Copyright © 2015 Rob Rix. All rights reserved.

final class EvaluationTests: XCTestCase {
	func testTypeEvaluatesToItself() {
		assert(try? Term(.Type(0)).evaluate(), ==, .Type(0))
	}

	func testApplicationOfIdentityAbstractionToTermEvaluatesToTerm() {
		let identity: Term = .Type => id
		assert(try? Term.Application(identity, .Type).evaluate(), ==, .Type)
	}

	func testSimpleAbstractionEvaluatesToItself() {
		let identity: Term = .Type => id
		assert(try? identity.evaluate(), ==, identity)
	}

	func testAbstractionsBodiesAreNotNormalized() {
		assert(try? identity.value.evaluate(), ==, identity.value)
	}
}

import Assertions
import Manifold
import Prelude
import XCTest
