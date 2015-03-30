//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Variable: Comparable, Hashable, IntegerLiteralConvertible, Printable {
	/// Constructs a fresh type variable.
	public init() {
		value = Variable.cursor++
	}


	public let value: Int


	// MARK: Hashable

	public var hashValue: Int {
		return value
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: IntegerLiteralType) {
		self.value = value
		Variable.cursor = max(Variable.cursor, value + 1)
	}


	// MARK: Printable

	public var description: String {
		return value.description
	}


	// MARK: Private

	private static var cursor = 0
}


public func == (left: Variable, right: Variable) -> Bool {
	return left.value == right.value
}


public func < (left: Variable, right: Variable) -> Bool {
	return left.value < right.value
}
