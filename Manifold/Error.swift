//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Error: Equatable, CustomStringConvertible, StringInterpolationConvertible, StringLiteralConvertible {
	public init(reason: String) {
		self = Leaf(reason)
	}


	case Leaf(String)
	case Branch([Error])


	public var errors: [Error] {
		return analysis(
			ifLeaf: const([ self ]),
			ifBranch: id)
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
		return analysis(
			ifLeaf: transform >>> Error.Leaf,
			ifBranch: { Error.Branch($0.map { $0.map(transform) }) })
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return analysis(
			ifLeaf: id,
			ifBranch: { $0.lazy.map { String($0) }.joinWithSeparator("\n") })
	}


	// MARK: StringInterpolationConvertible

	public init(stringInterpolation strings: Error...) {
		self = Error(reason: strings.reduce("") {
			$0 + $1.analysis(
				ifLeaf: id,
				ifBranch: const(""))
		})
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
