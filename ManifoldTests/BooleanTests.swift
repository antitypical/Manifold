//  Copyright © 2015 Rob Rix. All rights reserved.

final class BooleanTests: XCTestCase {
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

private let module = Module.boolean
private let expected: Module = {
	let Boolean = Declaration("Boolean",
		type: .Type,
		value: .Type => { ($0, $0) => const($0) })

	let `true` = Declaration("true",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { a, _ in a } })

	let `false` = Declaration("false",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { _, b in b } })

	return Module("ChurchBoolean", [ Boolean, `true`, `false` ])
}()

import Assertions
import Manifold
import Prelude
import XCTest
