//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		let expected: Term = .Type
		XCTAssertEqual(booleanModule.context["Boolean"].map(Term.init), expected)
	}

	func testDatatypeDeclarationsAddDataConstructorsToContext() {
		XCTAssertEqual(booleanModule.context["true"].map(Term.init), Term.Variable("Boolean"))
		XCTAssertEqual(booleanModule.context["false"].map(Term.init), Term.Variable("Boolean"))
	}

	func testDatatypeDeclarationsAddDataConstructorsToEnvironment() {
		XCTAssertEqual(booleanModule.environment["true"].map(Term.init), Term.Product(.Boolean(true), .Unit))
		XCTAssertEqual(booleanModule.environment["false"].map(Term.init), Term.Product(.Boolean(false), .Unit))
	}

	func testDatatypeConstructorsProduceRightNestedValues() {
		XCTAssertEqual(selfModule.environment["me"].map(Term.init), Term.Product(.Boolean(true), .Unit))
		XCTAssertEqual(selfModule.environment["myself"].map(Term.init), Term.Product(.Boolean(false), .Product(.Boolean(true), .Unit)))
		XCTAssertEqual(selfModule.environment["I"].map(Term.init), Term.Product(.Boolean(false), .Product(.Boolean(false), .Unit)))
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


@testable import Manifold
import Prelude
import XCTest
