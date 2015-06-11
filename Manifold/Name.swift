//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name: Hashable, IntegerLiteralConvertible, DebugPrintable, Printable, StringLiteralConvertible {
	// MARK: Constructors

	public static func global(name: String) -> Name {
		return .Global(name)
	}

	public static func local(index: Int) -> Name {
		return .Local(index)
	}


	// MARK: Destructors

	public var global: String? {
		return analysis(ifGlobal: unit, ifLocal: const(nil), ifQuote: const(nil))
	}

	public var value: Int? {
		return analysis(ifGlobal: const(nil), ifLocal: unit, ifQuote: unit)
	}


	// MARK: Analysis

	public func analysis<T>(
		@noescape ifGlobal ifGlobal: String -> T,
		@noescape ifLocal: Int -> T,
		@noescape ifQuote: Int -> T) -> T {
		switch self {
		case let .Global(s):
			return ifGlobal(s)
		case let .Local(n):
			return ifLocal(n)
		case let .Quote(n):
			return ifQuote(n)
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifGlobal: { "Global(\($0))" },
			ifLocal: { "Local(\($0))" },
			ifQuote: { "Quote(\($0))" })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return analysis(ifGlobal: { $0.hashValue }, ifLocal: id, ifQuote: id)
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: IntegerLiteralType) {
		self = Local(value)
	}


	// MARK: Printable

	public var description: String {
		return analysis(
			ifGlobal: id,
			ifLocal: toString,
			ifQuote: toString)
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
	case Quote(Int)
}


import Prelude
