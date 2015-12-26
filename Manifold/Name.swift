//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Name: Comparable, CustomStringConvertible, Hashable, StringLiteralConvertible {
	static func fresh(set: Set<Name>) -> Name {
		return Name.Local(0).fresh(set)
	}

	func fresh(isUsed: Name -> Bool) -> Name {
		guard isUsed(self) else { return self }
		switch self {
		case let .Local(i):
			return Name.Local(i + 1).fresh(isUsed)
		case let .Global(string):
			return Name.Global(string + "ʹ").fresh(isUsed)
		}
	}

	func fresh(set: Set<Name>) -> Name {
		return fresh(set.contains)
	}


	// MARK: CustomStringConvertible

	public var description: String {
		switch self {
		case let .Global(name):
			return name
		case let .Local(i):
			return renderNumerals(i, "abcdefghijklmnopqrstuvwxyz")
		}
	}


	// MARK: Hashable

	public var hashValue: Int {
		switch self {
		case let .Global(name):
			return name.hashValue
		case let .Local(i):
			return i
		}
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self = Global(value)
	}


	// MARK: Cases

	case Global(String)
	case Local(Int)
}


public func == (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Global(x), .Global(y)):
		return x == y
	case let (.Local(x), .Local(y)):
		return x == y
	default:
		return false
	}
}


public func < (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Local(a), .Local(b)):
		return a < b
	case let (.Global(a), .Global(b)):
		return a < b
	case (.Local, .Global):
		return true
	case (.Global, .Local):
		return false
	}
}
