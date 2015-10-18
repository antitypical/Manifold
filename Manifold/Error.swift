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


	// MARK: Printable

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


/// Computes the conjunction of two `Either`s.
public func &&& <T, U> (a: Either<Error, T>, b: Either<Error, U>) -> Either<Error, (T, U)> {
	let right = (a.right &&& b.right).map(Either<Error, (T, U)>.right)
	let lefts = (a.left &&& b.left).map(+).map(Either<Error, (T, U)>.left)
	let left = (a.left.map(Either<Error, (T, U)>.left) ||| b.left.map(Either<Error, (T, U)>.left))?.either(ifLeft: Optional.Some, ifRight: Optional.Some)
	return (right ?? lefts ?? left)!
}


import Either
import Prelude
