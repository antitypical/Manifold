//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name: Hashable, DebugPrintable, Printable {
	// MARK: Destructors

	public var value: Int {
		return analysis(ifLocal: id, ifQuote: id)
	}

	public static func value(name: Name) -> Int {
		return name.value
	}


	// MARK: Analysis

	public func analysis<T>(
		@noescape #ifLocal: Int -> T,
		@noescape ifQuote: Int -> T) -> T {
		switch self {
		case let .Local(n):
			return ifLocal(n)
		case let .Quote(n):
			return ifQuote(n)
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifLocal: { "Local(\($0))" },
			ifQuote: { "Quote(\($0))" })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}


	// MARK: Printable

	public var description: String {
		return toString(value)
	}


	// MARK: Cases

	case Local(Int)
	case Quote(Int)
}


import Prelude
