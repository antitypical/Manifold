//  Copyright © 2015 Rob Rix. All rights reserved.

final class SigmaTests: XCTestCase {
	func testModuleTypechecks() {
		module.typecheck().forEach { XCTFail($0) }
	}

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		expected.definitions.forEach { symbol, type, value in
			assert(module.context[symbol], ==, type, message: "'\(symbol)' expected '\(type)', actual '\(module.context[symbol])'")
			assert(module.environment[symbol], ==, value, message: "'\(symbol)' expected '\(value)', actual '\(module.environment[symbol])'")
		}
	}
}

private let module = Module<Term>.sigma
private let expected: Module<Term> = {
	let Sigma = Declaration<Term>("Sigma",
		type: .Type => { A in (A --> .Type) --> .Type },
		value: .Type => { A in (A --> .Type, .Type) => { B, C in (A => { x in B[x] --> C }) --> C } })

	let sigma = Declaration("sigma",
		type: .Type => { A in (A --> .Type, A) => { (B, x: Term) in B[x] --> Sigma.ref[A, B] } },
		value: .Type => { A in (A --> .Type, A) => { B, x in (B[x], .Type) => { y, C in (A => { xʹ in B[xʹ] --> C }) => { f in f[x, y] } } } })

	return Module("ChurchSigma", [ Sigma, sigma ])
}()


import Assertions
import Manifold
import XCTest
