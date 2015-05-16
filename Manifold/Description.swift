//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Description<Index> {
	// MARK: Constructors

	public static func end(index: Index) -> Description {
		return .End(Box(index))
	}


	// MARK: Destructors

	var end: Index? {
		return analysis(
			ifEnd: unit,
			ifRecursive: const(nil))
	}



	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifEnd: Index -> T,
		@noescape ifRecursive: (Index, Description) -> T) -> T {
		switch self {
		case let .End(index):
			return ifEnd(index.value)
		case let .Recursive(index, description):
			return ifRecursive(index.value, description.value)
		}
	}


	// MARK: Cases

	case End(Box<Index>)
	case Recursive(Box<Index>, Box<Description>)
}


import Box
