//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Error: Printable, StringLiteralConvertible {
	public init(reason: String) {
		self = Leaf(reason)
	}


	case Leaf(String)
	case Branch([Error])


	// MARK: ExtendedGraphemeClusterLiteralConvertible

	public init(extendedGraphemeClusterLiteral value: String) {
		self.init(reason: value)
	}


	// MARK: Printable

	public var description: String {
		switch self {
		case let Leaf(reason):
			return reason
		case let Branch(errors):
			return join("\n", lazy(errors).map(toString))
		}
	}

	
	// MARK: StringLiteralConvertible

	public init(stringLiteral value: StringLiteralType) {
		self.init(reason: value)
	}


	// MARK: UnicodeScalarLiteral

	public init(unicodeScalarLiteral value: String) {
		self.init(reason: value)
	}
}

public func + (left: Error, right: Error) -> Error {
	switch (left, right) {
	case (.Leaf, .Leaf):
		return .Branch([ left, right ])

	case let (.Leaf, .Branch(errors)):
		return .Branch([ left ] + errors)

	case let (.Branch(errors), .Leaf):
		return .Branch(errors + [ right ])

	case let (.Branch(e1), .Branch(e2)):
		return .Branch(e1 + e2)
	}
}
