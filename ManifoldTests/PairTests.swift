//  Copyright © 2015 Rob Rix. All rights reserved.

final class PairTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		expected.definitions.forEach { symbol, type, value in
			assert(module.context[symbol], ==, type, message: "\(symbol)")
			assert(module.environment[symbol], ==, value, message: "\(symbol)")
		}
	}
}

private let module = Module<Term>.pair
private let expected: Module<Term> = {
	let Pair = Declaration("Pair",
		type: .Type --> .Type --> .Type,
		value: Term.lambda(.Type, .Type, .Type) { A, B, Result in .lambda(A --> B --> Result, const(Result)) })

	let pair = Declaration("pair",
		type: Term.lambda(.Type, .Type) { A, B in A --> B --> Pair.ref[A, B] },
		value: Term.lambda(.Type, .Type) { A, B in Term.lambda(A, B, .Type) { a, b, Result in Term.lambda(A --> B --> Result) { f in f[a, b] } } })

	return Module("ChurchPair", [ Pair, pair, ])
}()


import Assertions
import Manifold
import Prelude
import XCTest
