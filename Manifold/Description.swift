//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Description<Index> {
	// MARK: Constructors

	public static func end(index: Index) -> Description {
		return .End(Box(index))
	}

	public static func recursive(index: Index, _ description: Description) -> Description {
		return .Recursive(Box(index), Box(description))
	}

	public static func argument(index: Index, _ argument: Any -> Description) -> Description {
		return .Argument(Box(index), argument)
	}


	// MARK: Destructors

	public var end: Index? {
		return analysis(
			ifEnd: unit,
			ifRecursive: const(nil),
			ifArgument: const(nil))
	}

	public var recursive: (Index, Description)? {
		return analysis(
			ifEnd: const(nil),
			ifRecursive: unit,
			ifArgument: const(nil))
	}

	public var argument: (Index, Any -> Description)? {
		return analysis(
			ifEnd: const(nil),
			ifRecursive: const(nil),
			ifArgument: unit)
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifEnd: Index -> T,
		@noescape ifRecursive: (Index, Description) -> T,
		@noescape ifArgument: (Index, Any -> Description) -> T) -> T {
		switch self {
		case let .End(index):
			return ifEnd(index.value)
		case let .Recursive(index, description):
			return ifRecursive(index.value, description.value)
		case let .Argument(index, argument):
			return ifArgument(index.value, argument)
		}
	}


	// MARK: Cases

	case End(Box<Index>)
	case Recursive(Box<Index>, Box<Description>)
	case Argument(Box<Index>, Any -> Description)
}


import Box
import Prelude
