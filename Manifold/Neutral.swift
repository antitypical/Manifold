//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Neutral: DebugPrintable {
	// MARK: DebugPrintable

	public var debugDescription: String {
		switch self {
		case let .Parameter(n):
			return n.debugDescription
		case let .Application(n, v):
			return "\(toDebugString(n))(\(toDebugString(v)))"
		}
	}


	// MARK: Cases

	case Parameter(Name)
	case Application(Box<Neutral>, Value)
}


import Box
