//  Copyright © 2015 Rob Rix. All rights reserved.

public protocol TermContainerType: Equatable, CustomDebugStringConvertible, CustomStringConvertible {
	var out: Expression<Self> { get }
}

extension TermContainerType {
	public static func out(container: Self) -> Expression<Self> {
		return container.out
	}

	public func cata<Result>(transform: Expression<Result> -> Result) -> Result {
		return (Self.out >>> map { $0.cata(transform) } >>> transform)(self)
	}

	public func para<Result>(transform: Expression<(Self, Result)> -> Result) -> Result {
		return (Self.out >>> map { ($0, $0.para(transform)) } >>> transform)(self)
	}
}

public func == <Term: TermContainerType> (left: Term, right: Term) -> Bool {
	return left.out == right.out
}


public protocol TermType: IntegerLiteralConvertible, StringLiteralConvertible, TermContainerType {
	init(_: () -> Expression<Self>)
}

extension TermType {
	public init(_ expression: Expression<Self>) {
		self.init { expression }
	}

	public static func ana<A>(transform: A -> Expression<A>)(_ seed: A) -> Self {
		return seed |> (Self.init <<< map(ana(transform)) <<< transform)
	}

	public static func apo<A>(transform: A -> Expression<Either<Self, A>>)(_ seed: A) -> Self {
		return seed |> (Self.init <<< (map { $0.either(ifLeft: id, ifRight: apo(transform)) }) <<< transform)
	}
}


// MARK: - Implementation details

private func map<A, B>(@noescape transform: A -> B)(_ expression: Expression<A>) -> Expression<B> {
	return expression.map(transform)
}


import Either
import Prelude
