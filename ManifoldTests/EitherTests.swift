//  Copyright © 2015 Rob Rix. All rights reserved.

final class EitherTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		module.definitions.forEach { symbol, type, value in
			assert(expected.context[symbol], ==, type, message: "\(symbol)")
			assert(expected.environment[symbol], ==, value, message: "\(symbol)")
		}
	}
}

private let module = Module<Term>.either
private let expected: Module<Term> = {
	let Either = Declaration<Term>("Either",
		type: .Type --> .Type --> .Type,
		value: (.Type, .Type, .Type) => { L, R, Result in (L --> Result) --> (R --> Result) --> Result })

	let left = Declaration("left",
		type: (.Type, .Type) => { L, R in L --> Either.ref[L, R] },
		value: (.Type, .Type) => { L, R in (L, .Type) => { (l: Term, Result) in ((L --> Result), (R --> Result)) => { ifL, _ in ifL[l] } } })

	let right = Declaration("right",
		type: (.Type, .Type) => { L, R in R --> Either.ref[L, R] },
		value: (.Type, .Type) => { L, R in (R, .Type) => { (r: Term, Result) in ((L --> Result), (R --> Result)) => { _, ifR in ifR[r] } } })

	return Module("ChurchEither", [ Either, left, right ])
}()


import Assertions
@testable import Manifold
import XCTest
