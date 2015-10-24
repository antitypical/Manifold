//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Error: Equatable, CustomStringConvertible, StringInterpolationConvertible, StringLiteralConvertible {
	public init(errors: [String]) {
		self.errors = errors
	}

	public var errors: [String]

	public func map(transform: String -> String) -> Error {
		return Error(errors: errors.map(transform))
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return errors.lazy.map { String($0) }.joinWithSeparator("\n")
	}


	// MARK: StringInterpolationConvertible

	public init(stringInterpolation strings: Error...) {
		self.init(errors: [ strings.lazy.map { String($0) }.reduce("", combine: +) ])
	}

	public init<T>(stringInterpolationSegment expr: T) {
		self.init(errors: [ String(expr) ])
	}

	
	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self.init(errors: [ value ])
	}
}


public func == (left: Error, right: Error) -> Bool {
	return left.errors == right.errors
}


/// Constructs a composite error.
public func + (left: Error, right: Error) -> Error {
	return Error(errors: left.errors + right.errors)
}
