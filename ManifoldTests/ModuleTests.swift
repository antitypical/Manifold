//  Copyright © 2015 Rob Rix. All rights reserved.

final class ModuleTests: XCTestCase {
	func testModulesTypecheck() {
		for (_, module) in Module.modules {
			module.typecheck().forEach { XCTFail($0) }
		}
	}


	// MARK: Boolean

	func testEquivalenceOfEncodedAndDatatypeBooleans() {
		encodedBoolean.definitions.forEach { symbol, type, value in
			assert(Module.boolean.context[symbol], ==, type, message: "\(symbol)")
			assert(Module.boolean.environment[symbol], ==, value, message: "\(symbol)")
		}
	}


	// MARK: Natural

	func testZeroTypechecksAsNatural() {
		assert(try? zero.elaborateType(nil, Module.natural.environment, Module.natural.context), ==, .Unroll(Natural, .Variable(.Global("zero"))))
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(try? successor[zero].elaborateType(nil, Module.natural.environment, Module.natural.context), ==, .Unroll(Natural, .Application(.Unroll(Natural --> Natural, .Variable(.Global("successor"))), .Unroll(Natural, .Variable(.Global("zero"))))))
	}


	// MARK: Pair

	func testAutomaticallyEncodedDefinitionsAreEquivalentToHandEncodedDefinitions() {
		encodedPair.definitions.forEach { symbol, type, value in
			assert(Module.pair.context[symbol], ==, type, message: "\(symbol)")
			assert(Module.pair.environment[symbol], ==, value, message: "\(symbol)")
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


private let Natural: Term = "Natural"
private let successor: Term = "successor"
private let zero: Term = "zero"


private let encodedPair: Module = {
	let Pair = Declaration("Pair",
		type: .Type --> .Type --> .Type,
		value: (.Type, .Type, .Type) => { A, B, Result in (A --> B --> Result) => const(Result) })

	let pair = Declaration("pair",
		type: (.Type, .Type) => { A, B in A --> B --> Pair.ref[A, B] },
		value: (.Type, .Type) => { A, B in (A, B, .Type) => { a, b, Result in (A --> B --> Result) => { f in f[a, b] } } })

	return Module("EncodedPair", [ Pair, pair, ])
}()


import Assertions
import Manifold
import Prelude
import XCTest
