//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		assert(Module.boolean.context["Boolean"], ==, .Type(0))
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(Module.boolean.context["true"], ==, .Variable("Boolean"))
		assert(Module.boolean.context["false"], ==, .Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(Module.boolean.environment["true"], Term.equate, .Type => { A in A => { a in A --> a } })
		assert(Module.boolean.environment["false"], Term.equate, .Type => { A in A --> A => id })
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		let Natural: Term = "Natural"
		assert(Module.natural.environment["successor"], Term.equate, (Natural, .Type) => { n, A in A --> (Natural --> A) => { $0[n] } })
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(datatype.context["a"], Term.equate, (.Type, .Type) => const("A"))
		assert(datatype.context["b"], Term.equate, (.Type, .Type) => const("A"))
	}

	func testDatatypeConstructorsWithArgumentsAreEncodedFunctions() {
		assert(datatype.environment["a"], Term.equate, (.Type, .Type, .Type) => { a, b, C in (.Type --> .Type --> C) => { (.Type --> .Type --> C) --> $0[a, b] } })
		assert(datatype.environment["b"], Term.equate, (.Type, .Type, .Type) => { a, b, C in (.Type --> .Type --> C) --> (.Type --> .Type --> C) => { $0[a, b] } })
	}
}


private let datatype = Module("A", [], [
	Declaration.Datatype("A", [
		"a": Telescope.Argument("x", .Type, .Argument("y", .Type, .End)),
		"b": Telescope.Argument("x", .Type, .Argument("y", .Type, .End)),
	])
])


import Assertions
@testable import Manifold
import Prelude
import XCTest
