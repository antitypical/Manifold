//  Copyright © 2015 Rob Rix. All rights reserved.

extension StringLiteralConvertible where StringLiteralType == String {
	public init(unicodeScalarLiteral: String) {
		self.init(stringLiteral: unicodeScalarLiteral)
	}

	public init(extendedGraphemeClusterLiteral: String) {
		self.init(stringLiteral: extendedGraphemeClusterLiteral)
	}
}
