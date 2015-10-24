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

	func testDatatypeConstructorWithArgumentsHasFunctionType() {
		assert(oneConstructorWithArgumentModule.context["a"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorWithArgumentsProducesFunction() {
		assert(oneConstructorWithArgumentModule.environment["a"], ==, (.BooleanType, .Type) => { b, A in (.BooleanType --> A) => { $0[b] } })
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithArgumentsModule.context["a"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["b"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["c"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		let Natural: Term = "Natural"
		assert(Module<Term>.natural.environment["successor"], ==, (Natural, .Type) => { n, A in A --> (Natural --> A) => { $0[n] } })
	}

	func testDatatypeConstructorsWithMultipleArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithMultipleArgumentsModule.context["a"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["b"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["c"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithMultipleArgumentsProduceFunctionsWhichTakeAndApplyEliminators() {
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["a"], ==, (.BooleanType, .BooleanType, .Type) => { a, b, C in (.BooleanType --> .BooleanType --> C) => { (.BooleanType --> .BooleanType --> C) --> (.BooleanType --> .BooleanType --> C) --> $0[a, b] } })
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["b"], ==, (.BooleanType, .BooleanType, .Type) => { a, b, C in (.BooleanType --> .BooleanType --> C) --> (.BooleanType --> .BooleanType --> C) => { (.BooleanType --> .BooleanType --> C) --> $0[a, b] } })
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["c"], ==, (.BooleanType, .BooleanType, .Type) => { a, b, C in (.BooleanType --> .BooleanType --> C) --> (.BooleanType --> .BooleanType --> C) --> (.BooleanType --> .BooleanType --> C) => { $0[a, b] } })
	}
}


private let selfModule = Module<Term>("Self", [], [
	Declaration.Datatype("Self", [
		"me": .End,
		"myself": .End,
		"I": .End,
	])
])

private let oneConstructorWithArgumentModule = Module<Term>("A", [], [
	Declaration.Datatype("A", [
		"a": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithArgumentsModule = Module<Term>("A", [], [
	Declaration.Datatype("A", [
		"a": .Argument(.BooleanType, const(.End)),
		"b": .Argument(.BooleanType, const(.End)),
		"c": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithMultipleArgumentsModule = Module<Term>("A", [], [
	Declaration.Datatype("A", [
		"a": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"b": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"c": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
	])
])


import Assertions
@testable import Manifold
import Prelude
import XCTest
