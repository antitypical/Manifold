//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Variable: Hashable, IntegerLiteralConvertible, Printable {
	/// Constructs a fresh type variable.
	public init() {
		self.value = Variable.cursor++
	}


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: IntegerLiteralType) {
		self.value = value
	}


	// MARK: Printable

	public var description: String {
		return value.description
	}


	// MARK: Private

	private static var cursor = 0

	private let value: Int
}


public func == (left: Variable, right: Variable) -> Bool {
	return left.value == right.value
}
