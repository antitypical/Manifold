//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Error: Equatable, CustomStringConvertible, StringInterpolationConvertible, StringLiteralConvertible {
	public init(reason: String) {
		self = Leaf(reason)
	}


	case Leaf(String)
	case Branch([Error])


	public var errors: [Error] {
		switch self {
		case .Leaf:
			return [ self ]
		case let .Branch(errors):
			return errors
		}
	}


	public func analysis<T>(@noescape ifLeaf ifLeaf: String -> T, @noescape ifBranch: [Error] -> T) -> T {
		switch self {
		case let Leaf(string):
			return ifLeaf(string)
		case let Branch(errors):
			return ifBranch(errors)
		}
	}


	public func map(transform: String -> String) -> Error {
		switch self {
		case let .Leaf(reason):
			return .Leaf(transform(reason))
		case let .Branch(errors):
			return .Branch(errors.map { $0.map(transform) })
		}
	}


	// MARK: CustomStringConvertible

	public var description: String {
		switch self {
		case let .Leaf(reason):
			return reason
		case let .Branch(errors):
			return errors.lazy.map { String($0) }.joinWithSeparator("\n")
		}
	}


	// MARK: StringInterpolationConvertible

	public init(stringInterpolation strings: Error...) {
		self = Error(reason: strings.lazy.map { String($0) }.reduce("", combine: +))
	}

	public init<T>(stringInterpolationSegment expr: T) {
		self = Error(reason: String(expr))
	}

	
	// MARK: StringLiteralConvertible

	public init(stringLiteral value: StringLiteralType) {
		self.init(reason: value)
	}
}


public func == (left: Error, right: Error) -> Bool {
	return zip(left.errors, right.errors)
		.lazy
		.map(==).reduce(true) { $0 && $1 }
}


/// Constructs a composite error.
public func + (left: Error, right: Error) -> Error {
	return Error.Branch(left.errors + right.errors)
}


import Either
import Prelude
