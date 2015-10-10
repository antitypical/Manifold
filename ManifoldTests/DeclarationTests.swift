//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		assert(Expression<Term>.boolean.context["Boolean"], ==, .Type(0))
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(Expression<Term>.boolean.context["true"], ==, .Variable("Boolean"))
		assert(Expression<Term>.boolean.context["false"], ==, .Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(Expression<Term>.boolean.environment["true"], ==, .Product(true, .Unit))
		assert(Expression<Term>.boolean.environment["false"], ==, .Product(false, .Unit))
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
		assert(Expression<Term>.natural.environment["successor"], ==, Expression.lambda("Natural") { .Product(false, .Product($0, .Unit)) })
	}

	func testDatatypeConstructorsWithMultipleArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithMultipleArgumentsModule.context["a"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["b"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["c"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithMultipleArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["a"], ==, .lambda(.BooleanType, .BooleanType, { .Product(true, .Product($0, .Product($1, .Unit))) }))
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["b"], ==, .lambda(.BooleanType, .BooleanType, { .Product(false, .Product(true, .Product($0, .Product($1, .Unit)))) }))
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["c"], ==, .lambda(.BooleanType, .BooleanType, { .Product(false, .Product(false, .Product($0, .Product($1, .Unit)))) }))
	}
}


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


import Assertions
@testable import Manifold
import Prelude
import XCTest
