//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		assert(booleanModule.context["Boolean"], ==, .Type(0))
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(booleanModule.context["true"], ==, .Variable("Boolean"))
		assert(booleanModule.context["false"], ==, .Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(booleanModule.environment["true"], ==, .Product(true, .Unit))
		assert(booleanModule.environment["false"], ==, .Product(false, .Unit))
	}

	func testDatatypeConstructorsProduceRightNestedValues() {
		assert(selfModule.environment["me"], ==, .Product(true, .Unit))
		assert(selfModule.environment["myself"], ==, .Product(false, .Product(true, .Unit)))
		assert(selfModule.environment["I"], ==, .Product(false, .Product(false, .Unit)))
	}

	func testDatatypeConstructorWithArgumentsHasFunctionType() {
		assert(oneConstructorWithArgumentModule.context["a"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorWithArgumentsProducesFunction() {
		assert(oneConstructorWithArgumentModule.environment["a"], ==, .lambda(.BooleanType, { .Product($0, .Unit) }))
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithArgumentsModule.context["a"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["b"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["c"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithArgumentsModule.environment["a"], ==, .lambda(.BooleanType, { .Product(true, .Product($0, .Unit)) }))
		assert(multipleConstructorsWithArgumentsModule.environment["b"], ==, .lambda(.BooleanType, { .Product(false, .Product(true, .Product($0, .Unit))) }))
		assert(multipleConstructorsWithArgumentsModule.environment["c"], ==, .lambda(.BooleanType, { .Product(false, .Product(false, .Product($0, .Unit))) }))
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		assert(naturalModule.environment["successor"], ==, Expression.lambda("Natural") { .Product(false, .Product($0, .Unit)) })
	}

	func testDatatypeConstructorsWithMultipleArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithMultipleArgumentsModule.context["a"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["b"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["c"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithMultipleArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithArgumentsModule.environment["a"], ==, .lambda(.BooleanType, .BooleanType, { .Product(true, .Product($0, .Product($1, .Unit))) }))
		assert(multipleConstructorsWithArgumentsModule.environment["b"], ==, .lambda(.BooleanType, .BooleanType, { .Product(false, .Product(true, .Product($0, .Product($1, .Unit)))) }))
		assert(multipleConstructorsWithArgumentsModule.environment["c"], ==, .lambda(.BooleanType, .BooleanType, { .Product(false, .Product(false, .Product($0, .Product($1, .Unit)))) }))
	}
}


private let booleanModule = Module<Term>([], [
	Declaration.Datatype("Boolean", [
		"true": .End,
		"false": .End,
	])
])


private let selfModule = Module<Term>([], [
	Declaration.Datatype("Self", [
		"me": .End,
		"myself": .End,
		"I": .End,
	])
])

private let oneConstructorWithArgumentModule = Module<Term>([], [
	Declaration.Datatype("A", [
		"a": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithArgumentsModule = Module<Term>([], [
	Declaration.Datatype("A", [
		"a": .Argument(.BooleanType, const(.End)),
		"b": .Argument(.BooleanType, const(.End)),
		"c": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithMultipleArgumentsModule = Module<Term>([], [
	Declaration.Datatype("A", [
		"a": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"b": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"c": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
	])
])

private let naturalModule = Module<Term>([], [
	Declaration.Datatype("Natural", [
		"zero": .End,
		"successor": .Argument("Natural", const(.End))
	])
])


import Assertions
@testable import Manifold
import Prelude
import XCTest
