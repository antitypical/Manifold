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
}


private let booleanModule = Module<Term>([], [
	Declaration.Datatype("Boolean", [
		"true": .End,
		"false": .End,
	])
])


@testable import Manifold
import Prelude
import XCTest
