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
		switch self {
		case let .Global(name):
			return ".Global(\(name))"
		case let .Local(i):
			return ".Local(\(i))"
		}
	}


	// MARK: CustomStringConvertible

	public var description: String {
		switch self {
		case let .Global(name):
			return name
		case let .Local(i):
			return renderNumerals(i, "abcdefghijklmnopqrstuvwxyz")
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		switch self {
		case let .Global(name):
			return name.hashValue
		case let .Local(i):
			return i
		}
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
