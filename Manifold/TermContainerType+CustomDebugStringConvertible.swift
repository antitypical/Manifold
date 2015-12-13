//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	public var debugDescription: String {
		return cata {
			switch $0 {
			case let .Type(n):
				return ".Type(\(n))"
			case let .Variable(n):
				return ".Variable(\(String(reflecting: n)))"
			case let .Application(a, b):
				return ".Application(\(a), \(b))"
			case let .Lambda(i, a, b):
				return ".Lambda(\(i), \(a), \(b))"
			case let .Embedded(value, type):
				return ".Embedded(\(String(reflecting: value)), \(type))"
			}
		}
	}
}
