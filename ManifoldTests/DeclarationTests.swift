//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		assert(Module<Term>.boolean.context["Boolean"], ==, .Type(0))
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(Module<Term>.boolean.context["true"], ==, .Variable("Boolean"))
		assert(Module<Term>.boolean.context["false"], ==, .Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(Module<Term>.boolean.environment["true"], ==, .Type => { A in A => { a in A --> a } })
		assert(Module<Term>.boolean.environment["false"], ==, .Type => { A in A --> A => id })
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		let Natural: Term = "Natural"
		assert(Module<Term>.natural.environment["successor"], ==, (Natural, .Type) => { n, A in A --> (Natural --> A) => { $0[n] } })
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(datatype.context["a"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(datatype.context["b"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithArgumentsAreEncodedFunctions() {
		assert(datatype.environment["a"], ==, (.BooleanType, .BooleanType, .Type) => { a, b, C in (.BooleanType --> .BooleanType --> C) => { (.BooleanType --> .BooleanType --> C) --> $0[a, b] } })
		assert(datatype.environment["b"], ==, (.BooleanType, .BooleanType, .Type) => { a, b, C in (.BooleanType --> .BooleanType --> C) --> (.BooleanType --> .BooleanType --> C) => { $0[a, b] } })
	}
}


private let datatype = Module<Term>("A", [], [
	Declaration.Datatype("A", [
		"a": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"b": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
	])
])


import Assertions
@testable import Manifold
import Prelude
import XCTest
