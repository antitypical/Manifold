//  Copyright © 2015 Rob Rix. All rights reserved.

final class ElaborationTests: XCTestCase {
	func testInfersTheTypeOfType() {
		let term: Term = .Type
		assert(try? term.elaborateType(nil, [:], [:]), ==, .Unroll(.Type(1), .Identity(.Type(0))))
	}

	func testChecksLambdasAgainstFunctionTypes() {
		let actual = try? Term.Lambda(.Local(0), .Type, 0).elaborateType(.Type --> .Type, [:], [:])
		let expected: AnnotatedTerm<Term> = .Unroll(.Type --> .Type, .Identity(.Lambda(.Unroll(.Type(1), .Identity(.Type(0))), .Unroll(.Type, .Abstraction(.Local(0), .Unroll(.Type, .Variable(.Local(0))))))))
		assert(actual, ==, expected)
	}

	func testChecksLambdasAgainstDependentFunctionTypes() {
		let type = .Type => { A in A --> A }
		let term = .Type => { A in A => { a in a } }
		let elaborated = assertNoThrow(try term.elaborateType(type, [:], [:]))
		assert(elaborated?.annotation, ==, type)
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
