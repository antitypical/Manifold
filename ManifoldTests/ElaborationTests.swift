//  Copyright © 2015 Rob Rix. All rights reserved.

final class ElaborationTests: XCTestCase {
	func testInfersTheTypeOfType() {
		let term: Term = .Type
		assert(try? term.elaborateType(nil, [:], [:]), ==, .Unroll(.Type(1), .Identity(.Type(0))))
	}

	func testChecksLambdasAgainstFunctionTypes() {
		let type = .Type --> .Type
		let term = .Type => { $0 }
		assert(try term.elaborateType(type, [:], [:]).annotation, ==, type)
	}

	func testChecksLambdasAgainstDependentFunctionTypes() {
		let type = .Type => { A in A --> A }
		let term = .Type => { A in A => { a in a } }
		assert(try term.elaborateType(type, [:], [:]).annotation, ==, type)
	}

	func testChecksApplicationsOfLambdas() {
		let type = .Type --> (.Type --> .Type) --> .Type
		let term = Term.Lambda(.Local(0), .Type, .Lambda(.Local(1), .Type --> .Type, (1 as Term)[0 as Term]))
		assert(try term.elaborateType(type, [:], [:]).annotation, ==, type)
	}
}

func assertNoThrow<A>(@autoclosure test: () throws -> A, file: String = __FILE__, line: UInt = __LINE__) -> A? {
	do {
		return try test()
	} catch {
		XCTFail("\(error)", file: file, line: line)
		return nil
	}
}


import Assertions
import Manifold
import XCTest
