//  Copyright © 2015 Rob Rix. All rights reserved.

public protocol TermContainerType: Equatable {
	var out: Expression<Self> { get }
}

public protocol TermType: BooleanLiteralConvertible, CustomDebugStringConvertible, CustomStringConvertible, IntegerLiteralConvertible, StringLiteralConvertible, TermContainerType {
	init(_: () -> Expression<Self>)
}

extension TermType {
	public init(_ expression: Expression<Self>) {
		self.init { expression }
	}

	public static func out(fixpoint: Self) -> Expression<Self> {
		return fixpoint.out
	}
}


public func == <Term: TermContainerType> (left: Term, right: Term) -> Bool {
	return left.out == right.out
}


// MARK: - Fix: TermType over Expression<Fix>

public func cata<T, Fix: TermType>(f: Expression<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (map <| cata(f)) >>> f)
}

public func para<T, Fix: TermType>(f: Expression<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (Fix.out >>> (map <| fanout) >>> f)
}


public func ana<T, Fix: TermType>(f: T -> Expression<T>)(_ seed: T) -> Fix {
	return seed |> (Fix.init <<< (map <| ana(f)) <<< f)
}


public func apo<T>(f: T -> Expression<Either<Term, T>>)(_ seed: T) -> Term {
	return seed |> (Term.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


// MARK: - Implementation details

private func map<T, U>(f: T -> U)(_ c: Expression<T>) -> Expression<U> {
	return Expression.map(c)(f)
}


import Either
import Prelude
