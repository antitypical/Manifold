//  Copyright (c) 2014 Rob Rix. All rights reserved.

extension XCTestCase {
	func assertEqual<T: Equatable>(@autoclosure expression1:  () -> T?, @autoclosure _ expression2:  () -> T?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> T? {
		let (actual, expected) = (expression1(), expression2())
		return actual == expected ? actual : failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
	}

	func assertEqual<T: Equatable, U: Equatable>(@autoclosure expression1:  () -> Either<T, U>?, @autoclosure _ expression2:  () -> Either<T, U>?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> Either<T, U>? {
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

	func assertEqual<T: Equatable, U: Equatable>(@autoclosure expression1:  () -> Either<T, U>?, @autoclosure _ expression2:  () -> U?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> Either<T, U>? {
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

	func assertEqual<T: Equatable>(@autoclosure expression1:  () -> [T]?, @autoclosure _ expression2:  () -> [T]?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> [T]? {
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

	func assertEqual(@autoclosure expression1:  () -> ()?, _ expected: ()?, _ message: String = "", _ file: String = __FILE__, _ line: UInt = __LINE__) -> ()? {
		let actual: ()? = expression1()
		switch (actual, expected) {
		case (.None, .None), (.Some, .Some):
			return ()
		default:
			return failure("\(actual) is not equal to \(expected). " + message, file: file, line: line)
		}
	}

	func assertEqual<T: Hashable>(@autoclosure expression1:  () -> Set<T>?, @autoclosure expression2:  () -> Set<T>?) -> Set<T>? {
		let (actual, expected) = (expression1(), expression2())
		switch (actual, expected) {
		case (.None, .None):
			return actual
		case let (.Some(x), .Some(y)) where x == y:
			return actual
		default:
			return failure("\(actual) is not equal to \(expected).")
		}
	}

	func assertNil<T>(@autoclosure expression:  () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> Bool {
		return expression().map { self.failure("\($0) is not nil. " + message, file: file, line: line) } ?? true
	}

	func assertNotNil<T>(@autoclosure expression:  () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> T? {
		return expression() ?? failure("is nil. " + message, file: file, line: line)
	}

	func assertLeft<T, U>(@autoclosure expression:  () -> Either<T, U>, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> T? {
		let either = expression()
		return assertNotNil(either.left, "is unexpectedly \(either)" + message, file: file, line: line)
	}

	func assertRight<T, U>(@autoclosure expression:  () -> Either<T, U>, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> U? {
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
}


// MARK: - Imports

import Either
import Prelude
import Set
import XCTest
