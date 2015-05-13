//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name: Hashable, DebugPrintable, Printable, StringLiteralConvertible {
	// MARK: Destructors

	public var global: String? {
		return analysis(ifGlobal: unit, ifLocal: const(nil), ifQuote: const(nil))
	}

	public var value: Int? {
		return analysis(ifGlobal: const(nil), ifLocal: unit, ifQuote: unit)
	}


	// MARK: Analysis

	public func analysis<T>(
		@noescape #ifGlobal: String -> T,
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


	// MARK: Printable

	public var description: String {
		return toString(value)
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
