//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).inferType(), ==, .Type(1))
	}

	func testApplicationOfIdentityAbstractionToTermTypechecksToType() {
		let identity = Term.lambda(.Type(1), id)
		assert(Term.Application(identity, .Type).inferType(), ==, .Type(1))
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.lambda(.Type, id)
		assert(identity.inferType(), ==, .lambda(.Type, const(.Type)))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.inferType(), ==, .Lambda(0, .Type, .Lambda(-1, 0, 0)))
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

