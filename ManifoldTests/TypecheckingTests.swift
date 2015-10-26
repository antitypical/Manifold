//  Copyright © 2015 Rob Rix. All rights reserved.

final class TypecheckingTests: XCTestCase {
	func testTypeTypechecksToNextTypeLevel() {
		assert(Term(.Type(0)).inferType(), ==, .Unroll(.Type(1), .Type(0)))
	}

	func testApplicationOfIdentityAbstractionToTermTypechecksToType() {
		assert(Term.Application("identity", .Type).checkType(.Type, [:], [ "identity": .lambda(.Type(1), id) ]), ==, .Unroll(.Type, .Application(.Unroll(.Type(1) => id, .Variable(.Global("identity"))), .Unroll(.Type(1), .Type(0)))))
	}

	func testSimpleAbstractionTypechecksToAbstractionType() {
		let identity = Term.lambda(.Type, id)
		assert(identity.checkType(.Lambda(-1, .Type(0), .Type(0)), [:], [:]), ==, .Unroll(.Type --> .Type, .Lambda(0, .Unroll(.Type(1), .Type(0)), .Unroll(.Type(0), .Variable(.Local(0))))))
	}

	func testAbstractedAbstractionTypechecks() {
		assert(identity.value.checkType(identity.type, [:], [:]), ==, .Unroll(identity.type, .Lambda(1, .Unroll(.Type(1), .Type(0)), .Unroll(.Lambda(-1, .Variable(.Local(1)), .Variable(.Local(1))), .Lambda(0, .Unroll(.Type(0), .Variable(.Local(1))), .Unroll(.Variable(.Local(1)), .Variable(.Local(0))))))))
	}
}

import Assertions
@testable import Manifold
import Prelude
import XCTest

