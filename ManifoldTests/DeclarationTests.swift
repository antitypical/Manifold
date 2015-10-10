//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		assert(booleanModule.context["Boolean"].map(Term.init), ==, .Type)
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(booleanModule.context["true"].map(Term.init), ==, Term.Variable("Boolean"))
		assert(booleanModule.context["false"].map(Term.init), ==, Term.Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(booleanModule.environment["true"].map(Term.init), ==, Term.Product(true, .Unit))
		assert(booleanModule.environment["false"].map(Term.init), ==, Term.Product(false, .Unit))
	}

	func testDatatypeConstructorsProduceRightNestedValues() {
		assert(selfModule.environment["me"].map(Term.init), ==, Term.Product(true, .Unit))
		assert(selfModule.environment["myself"].map(Term.init), ==, Term.Product(false, .Product(true, .Unit)))
		assert(selfModule.environment["I"].map(Term.init), ==, Term.Product(false, .Product(false, .Unit)))
	}

	func testDatatypeConstructorWithArgumentsHasFunctionType() {
		assert(oneConstructorWithArgumentModule.context["a"].map(Term.init), ==, Term.lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorWithArgumentsProducesFunction() {
		assert(oneConstructorWithArgumentModule.environment["a"].map(Term.init), ==, Term.lambda(.BooleanType, id))
	}

	func testDatatypeConstructorsWithArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithArgumentsModule.context["a"].map(Term.init), ==, Term.lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["b"].map(Term.init), ==, Term.lambda(.BooleanType, const("A")))
		assert(multipleConstructorsWithArgumentsModule.context["c"].map(Term.init), ==, Term.lambda(.BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithArgumentsModule.environment["a"].map(Term.init), ==, Term.lambda(.BooleanType, { .Product(true, $0) }))
		assert(multipleConstructorsWithArgumentsModule.environment["b"].map(Term.init), ==, Term.lambda(.BooleanType, { .Product(false, .Product(true, $0)) }))
		assert(multipleConstructorsWithArgumentsModule.environment["c"].map(Term.init), ==, Term.lambda(.BooleanType, { .Product(false, .Product(false, $0)) }))
	}

	func testDatatypeConstructorsWithRecursiveReferencesProduceValuesEmbeddingReferencesToTheirType() {
		assert(naturalModule.environment["successor"].map(Term.init), ==, Term.lambda("Natural") { .Product(false, $0) })
	}

	func testDatatypeConstructorsWithMultipleArgumentsHaveFunctionTypes() {
		assert(multipleConstructorsWithMultipleArgumentsModule.context["a"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["b"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, const("A")))
		assert(multipleConstructorsWithMultipleArgumentsModule.context["c"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, const("A")))
	}

	func testDatatypeConstructorsWithMultipleArgumentsProduceFunctionsReturningRightNestedValues() {
		assert(multipleConstructorsWithArgumentsModule.environment["a"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, { .Product(true, .Product($0, $1)) }))
		assert(multipleConstructorsWithArgumentsModule.environment["b"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, { .Product(false, .Product(true, .Product($0, $1))) }))
		assert(multipleConstructorsWithArgumentsModule.environment["c"].map(Term.init), ==, Term.lambda(.BooleanType, .BooleanType, { .Product(false, .Product(false, .Product($0, $1))) }))
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
