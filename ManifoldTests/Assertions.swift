//  Copyright © 2015 Rob Rix. All rights reserved.

func assert<L, R>(@autoclosure expression1: () -> Either<L, R>, _ test: (R, R) -> Bool, @autoclosure _ expression2: () -> R, message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> R? {
	switch expression1() {
	case let .Left(l):
		failure("expected success, but got: \(String(reflecting: l))", file: file, line: line)
		return nil
	case let .Right(r):
		let expected = expression2()
		return test(r, expected)
			? r
			: failure("\(String(reflecting: r)) did not match \(String(reflecting: expected))", file: file, line: line)
	}
}


import Assertions
import Either
