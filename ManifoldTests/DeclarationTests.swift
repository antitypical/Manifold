//  Copyright © 2015 Rob Rix. All rights reserved.

final class DeclarationTests: XCTestCase {
	func testDatatypeDeclarationsAddTypesToContext() {
		let expected: Term = .Type
		XCTAssertEqual(booleanModule.context["Boolean"].map(Term.init), expected)
	}
}


private let booleanModule = Module<Term>([], [
	Declaration.Datatype("Boolean", [
		("true", .End),
		("false", .End),
	])
])


@testable import Manifold
import XCTest
