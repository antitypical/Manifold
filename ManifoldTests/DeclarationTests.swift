//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		let expected: Term = .Type
		assert(booleanModule.context["Boolean"].map(Term.init), ==, expected)
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		assert(booleanModule.context["true"].map(Term.init), ==, Term.Variable("Boolean"))
		assert(booleanModule.context["false"].map(Term.init), ==, Term.Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		assert(booleanModule.environment["true"].map(Term.init), ==, Term.Product(.Boolean(true), .Unit))
		assert(booleanModule.environment["false"].map(Term.init), ==, Term.Product(.Boolean(false), .Unit))
	}

	func testDatatypeConstructorsProduceRightNestedValues() {
		assert(selfModule.environment["me"].map(Term.init), ==, Term.Product(.Boolean(true), .Unit))
		assert(selfModule.environment["myself"].map(Term.init), ==, Term.Product(.Boolean(false), .Product(.Boolean(true), .Unit)))
		assert(selfModule.environment["I"].map(Term.init), ==, Term.Product(.Boolean(false), .Product(.Boolean(false), .Unit)))
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


import Assertions
@testable import Manifold
import Prelude
import XCTest
