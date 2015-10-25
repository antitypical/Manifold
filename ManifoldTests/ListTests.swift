//  Copyright © 2015 Rob Rix. All rights reserved.

final class ListTests: XCTestCase {
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

private let module = Module<Term>.list
private let expected: Module<Term> = {
	let List: Term = "List"
	let list = Declaration("List",
		type: .Type --> .Type,
		value: (.Type, .Type) => { A, B in (A --> List[A] --> B) --> B --> B })

	let cons = Declaration("cons",
		type: .Type => { A in A --> List[A] --> List[A] },
		value: .Type => { (A: Term) in (A, List[A], .Type) => { head, tail, B in (A --> List[A] --> B, B) => { ifCons, _ in ifCons[head, tail] } } })

	let `nil` = Declaration("nil",
		type: .Type => { (A: Term) in List[A] },
		value: (.Type, .Type) => { A, B in (A --> List[A] --> B, B) => { _, other in other } })

	return Module("ChurchList", [ list, cons, `nil` ])
}()


import Assertions
@testable import Manifold
import Prelude
import XCTest
