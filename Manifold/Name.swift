//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Name: Hashable {
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


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}


	// MARK: Cases

	case Local(Int)
	case Quote(Int)
}


import Prelude
