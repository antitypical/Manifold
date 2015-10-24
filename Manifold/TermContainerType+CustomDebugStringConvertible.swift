//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	public var debugDescription: String {
		return cata {
			switch $0 {
			case .Unit:
				return ".Unit"
			case .UnitType:
				return ".UnitType"
			case let .Type(n):
				return ".Type(\(n))"
			case let .Variable(n):
				return ".Variable(\(n))"
			case let .Application(a, b):
				return ".Application(\(a), \(b))"
			case let .Lambda(i, a, b):
				return ".Lambda(\(i), \(a), \(b))"
			}
		}
	}
}
