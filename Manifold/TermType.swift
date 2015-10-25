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

	public static func ana<A>(f: A -> Expression<A>)(_ seed: A) -> Self {
		return seed |> (Self.init <<< map(ana(f)) <<< f)
	}

	public static func apo<A>(f: A -> Expression<Either<Self, A>>)(_ seed: A) -> Self {
		return seed |> (Self.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
	}
}


// MARK: - Term: TermType over Expression<Term>

public func apo<A>(f: A -> Expression<Either<Term, A>>)(_ seed: A) -> Term {
	return seed |> (Term.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


// MARK: - Implementation details

private func map<A, B>(@noescape transform: A -> B)(_ expression: Expression<A>) -> Expression<B> {
	return Expression.map(expression)(transform)
}


import Either
import Prelude
