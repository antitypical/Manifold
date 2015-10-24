//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	// MARK: Variables

	public var maxBoundVariable: Int {
		return cata {
			switch $0 {
			case .Type, .Variable:
				return -1
			case let .Application(a, b):
				return max(a, b)
			case let .Lambda(i, a, b):
				return i < 0 ? max(a, b) : max(i, a)
			}
		}
	}

	public var freeVariables: Set<Int> {
		return cata {
			switch $0 {
			case .Type, .Variable(.Global):
				return []
			case let .Variable(.Local(i)):
				return [ i ]
			case let .Application(a, b):
				return a.union(b)
			case let .Lambda(i, a, b):
				return a.union(b.subtract([ i ]))
			}
		}
	}
}


import Prelude
