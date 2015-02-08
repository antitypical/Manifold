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
