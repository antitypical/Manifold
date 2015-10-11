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
		assert(Expression<Term>.boolean.environment["true"], ==, .Annotation(.Product(true, .Unit), "Boolean"))
		assert(Expression<Term>.boolean.environment["false"], ==, .Annotation(.Product(false, .Unit), "Boolean"))
	}

	func testDatatypeConstructorsProduceRightNestedValues() {
		assert(selfModule.environment["me"], ==, .Annotation(.Product(true, .Unit), "Self"))
		assert(selfModule.environment["myself"], ==, .Annotation(.Product(false, .Product(true, .Unit)), "Self"))
		assert(selfModule.environment["I"], ==, .Annotation(.Product(false, .Product(false, .Unit)), "Self"))
	}

	func testDatatypeConstructorWithArgumentsHasFunctionType() {
		assert(oneConstructorWithArgumentModule.context["a"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorWithArgumentsProducesFunction() {
		assert(oneConstructorWithArgumentModule.environment["a"], ==, .lambda(.BooleanType, { .Annotation($0, "A") }))
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithArgumentsModule.context["a"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["b"], ==, .lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["c"], ==, .lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithArgumentsModule.environment["a"], ==, .lambda(.BooleanType, { .Annotation(.Product(true, $0), "A") }))
		assert(multipleConstructorsWithArgumentsModule.environment["b"], ==, .lambda(.BooleanType, { .Annotation(.Product(false, .Product(true, $0)), "A") }))
		assert(multipleConstructorsWithArgumentsModule.environment["c"], ==, .lambda(.BooleanType, { .Annotation(.Product(false, .Product(false, $0)), "A") }))
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		assert(Expression<Term>.natural.environment["successor"], ==, Expression.lambda("Natural") { .Annotation(.Product(false, $0), "Natural") })
	}

	func testDatatypeConstructorsWithMultipleArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithMultipleArgumentsModule.context["a"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["b"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["c"], ==, .lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithMultipleArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["a"], ==, .lambda(.BooleanType, .BooleanType, { .Annotation(.Product(true, .Product($0, $1)), "A") }))
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["b"], ==, .lambda(.BooleanType, .BooleanType, { .Annotation(.Product(false, .Product(true, .Product($0, $1))), "A") }))
		assert(multipleConstructorsWithMultipleArgumentsModule.environment["c"], ==, .lambda(.BooleanType, .BooleanType, { .Annotation(.Product(false, .Product(false, .Product($0, $1))), "A") }))
	}
}


private let selfModule = Module<Term>([], [
	Declaration.Datatype("Self", .Type(0), [
		"me": .End,
		"myself": .End,
		"I": .End,
	])
])

private let oneConstructorWithArgumentModule = Module<Term>([], [
	Declaration.Datatype("A", .Type(0), [
		"a": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithArgumentsModule = Module<Term>([], [
	Declaration.Datatype("A", .Type(0), [
		"a": .Argument(.BooleanType, const(.End)),
		"b": .Argument(.BooleanType, const(.End)),
		"c": .Argument(.BooleanType, const(.End)),
	])
])

private let multipleConstructorsWithMultipleArgumentsModule = Module<Term>([], [
	Declaration.Datatype("A", .Type(0), [
		"a": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"b": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
		"c": Telescope.Argument(.BooleanType) { a in .Argument(.BooleanType, const(.End)) },
	])
])


import Assertions
@testable import Manifold
import Prelude
import XCTest
