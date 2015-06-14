//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name: Hashable, IntegerLiteralConvertible, CustomDebugStringConvertible, CustomStringConvertible, StringLiteralConvertible {
	// MARK: Constructors

	public static func global(name: String) -> Name {
		return .Global(name)
	}

	public static func local(index: Int) -> Name {
		return .Local(index)
	}


	// MARK: Destructors

	public var global: String? {
		return analysis(ifGlobal: unit, ifLocal: const(nil))
	}

	public var value: Int? {
		return analysis(ifGlobal: const(nil), ifLocal: unit)
	}


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


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifGlobal: { "Global(\($0))" },
			ifLocal: { "Local(\($0))" })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(ifGlobal: { $0.hashValue }, ifLocal: id)
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: IntegerLiteralType) {
		self = Local(value)
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifGlobal: id,
			ifLocal: { String($0) })
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self = Global(value)
	}

	public init(unicodeScalarLiteral value: String) {
		self = Global(value)
	}

	public init(extendedGraphemeClusterLiteral value: String) {
		self = Global(value)
	}


	// MARK: Cases

	case Global(String)
	case Local(Int)
}


import Prelude
