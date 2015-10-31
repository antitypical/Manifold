//  Copyright © 2015 Rob Rix. All rights reserved.

final class ModuleTests: XCTestCase {
	func testModulesTypecheck() {
		for (_, module) in Module.modules {
			module.typecheck().forEach { XCTFail($0) }
		}
	}

	func testEquivalenceOfEncodedAndDatatypeBooleans() {
		encodedBoolean.definitions.forEach { symbol, type, value in
			assert(Module.boolean.context[symbol], ==, type, message: "\(symbol)")
			assert(Module.boolean.environment[symbol], ==, value, message: "\(symbol)")
		}
	}
}


private let encodedBoolean: Module = {
	let Boolean = Declaration("Boolean",
		type: .Type,
		value: .Type => { ($0, $0) => const($0) })

	let `true` = Declaration("true",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { a, _ in a } })

	let `false` = Declaration("false",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { _, b in b } })

	return Module("EncodedBoolean", [ Boolean, `true`, `false` ])
}()


import Assertions
import Manifold
import Prelude
import XCTest
