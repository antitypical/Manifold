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
			case let .Lambda(i, .Some(a), b):
				return i < 0 ? max(a, b) : max(i, a)
			case let .Lambda(i, .None, b):
				return i < 0 ? b : i
			}
		}
	}

	public var freeVariables: [Int] {
		return cata {
			switch $0 {
			case .Type, .Variable(.Global):
				return []
			case let .Variable(.Local(i)):
				return [ i ]
			case let .Application(a, b):
				return (a + b)
			case let .Lambda(i, a, b):
				return (a ?? []) + b.filter { $0 != i }
			}
		}
	}
}


extension Term {
	public func generalize() -> Term {
		return freeVariables.sort().reduce(self) {
			.Lambda($1, nil, $0)
		}
	}
}


import Prelude
