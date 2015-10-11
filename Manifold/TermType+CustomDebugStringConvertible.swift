//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
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
				return ".Variable(\(String(reflecting: n)))"
			case let .Application(a, b):
				return ".Application(\(String(reflecting: a)), \(String(reflecting: b)))"
			case let .Lambda(i, a, b):
				return ".Lambda(\(i), \(String(reflecting: a)), \(String(reflecting: b)))"
			case let .Projection(a, field):
				return ".Projection(\(String(reflecting: a)), \(field))"
			case let .Product(a, b):
				return ".Product(\(String(reflecting: a)), \(String(reflecting: b)))"
			case .BooleanType:
				return ".BooleanType"
			case let .Boolean(a):
				return ".Boolean(\(a))"
			case let .If(a, b, c):
				return ".If(\(String(reflecting: a)), \(String(reflecting: b)), \(String(reflecting: c)))"
			case let .Annotation(a, b):
				return ".Annotation(\(String(reflecting: a)), \(String(reflecting: b)))"
			}
		} (self)
	}
}
