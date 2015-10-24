//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Name: Comparable, CustomDebugStringConvertible, CustomStringConvertible, Hashable, IntegerLiteralConvertible, StringLiteralConvertible {
	// MARK: Analysis

	public func analysis<T>(
		@noescape ifGlobal ifGlobal: String -> T,
		@noescape ifLocal: Int -> T) -> T {
		switch self {
		case let .Global(s):
			return ifGlobal(s)
		case let .Local(n):
			return ifLocal(n)
		}
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return analysis(
			ifGlobal: { ".Global(\($0))" },
			ifLocal: { ".Local(\($0))" })
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return analysis(
			ifGlobal: id,
			ifLocal: { renderNumerals($0, "abcdefghijklmnopqrstuvwxyz") })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(ifGlobal: { $0.hashValue }, ifLocal: id)
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self = Local(value)
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self = Global(value)
	}


	// MARK: Cases

	case Global(String)
	case Local(Int)
}


public func == (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Global(x), .Global(y)):
		return x == y
	case let (.Local(x), .Local(y)):
		return x == y
	default:
		return false
	}
}


public func < (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Local(a), .Local(b)):
		return a < b
	case let (.Global(a), .Global(b)):
		return a < b
	case (.Local, .Global):
		return true
	case (.Global, .Local):
		return false
	}
}


import Prelude
