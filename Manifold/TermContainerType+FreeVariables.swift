//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	// MARK: Variables

	public var maxBoundVariable: Int {
		return cata {
			switch $0 {
			case .Type, .Variable, .Implicit:
				return -1
			case let .Application(a, b):
				return max(a, b)
			case let .Lambda(i, a, b):
				return i < 0 ? max(a, b) : max(i, a)
			case let .Embedded(_, _, type):
				return type
			}
		}
	}
}
