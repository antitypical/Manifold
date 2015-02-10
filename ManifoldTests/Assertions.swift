//  Copyright (c) 2014 Rob Rix. All rights reserved.

func assertEqual<T: Equatable>(expression1: @autoclosure () -> T?, expression2: @autoclosure () -> T?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> T? {
	let (actual, expected) = (expression1(), expression2())
	return actual == expected ? actual : failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
}

func assertEqual<T: Equatable, U: Equatable>(expression1: @autoclosure () -> Either<T, U>?, expression2: @autoclosure () -> Either<T, U>?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> Either<T, U>? {
	let (actual, expected) = (expression1(), expression2())
	switch (actual, expected) {
	case (.None, .None):
		return actual
	case let (.Some(x), .Some(y)) where x == y:
		return actual
	default:
		return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}
}

func assertEqual<T: Equatable, U: Equatable>(expression1: @autoclosure () -> Either<T, U>?, expression2: @autoclosure () -> U?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> Either<T, U>? {
	let (actual, expected) = (expression1(), expression2())
	switch (actual, expected) {
	case (.None, .None):
		return actual
	case let (.Some(.Right(x)), .Some(y)) where x.value == y:
		return actual
	default:
		return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}
}

func assertEqual<T: Equatable>(expression1: @autoclosure () -> [T]?, expression2: @autoclosure () -> [T]?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> [T]? {
	let (actual, expected) = (expression1(), expression2())
	switch (actual, expected) {
	case (.None, .None):
		return actual
	case let (.Some(x), .Some(y)) where x == y:
		return actual
	default:
		return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}
}

func assertEqual<T: Hashable, U: Equatable>(expression1: @autoclosure () -> [T: U]?, expression2: @autoclosure () -> [T: U]?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> [T: U]? {
	let (actual, expected) = (expression1(), expression2())
	switch (actual, expected) {
	case (.None, .None):
		return actual
	case let (.Some(x), .Some(y)) where x == y:
		return actual
	default:
		return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}
}


func assertEqual(expression1: @autoclosure () -> ()?, expected: ()?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> ()? {
	let actual: ()? = expression1()
	switch (actual, expected) {
	case (.None, .None), (.Some, .Some):
		return ()
	default:
		return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}
}

func assertNil<T>(expression: @autoclosure () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> Bool {
	return expression().map { failure("\($0) is not nil. " + message, file: file, line: line) } ?? true

}

func assertNotNil<T>(expression: @autoclosure () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> T? {
	return expression() ?? failure("is nil. " + message, file: file, line: line)
}

func assertLeft<T, U>(expression: @autoclosure () -> Either<T, U>, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> T? {
	let either = expression()
	return assertNotNil(either.left, "is unexpectedly \(either)" + message, file: file, line: line)
}

func assertRight<T, U>(expression: @autoclosure () -> Either<T, U>, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> U? {
	let either = expression()
	return assertNotNil(either.right, "is unexpectedly \(either)" + message, file: file, line: line)
}

func failure<T>(message: String, file: String = __FILE__, line: UInt = __LINE__) -> T? {
	XCTFail(message, file: file, line: line)
	return nil
}

func failure(message: String, file: String = __FILE__, line: UInt = __LINE__) -> Bool {
	XCTFail(message, file: file, line: line)
	return false
}


// MARK: - Imports

import Either
import Prelude
import XCTest
