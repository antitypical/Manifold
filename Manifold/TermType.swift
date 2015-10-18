//  Copyright © 2015 Rob Rix. All rights reserved.

public protocol TermContainerType: Equatable {
	var out: Expression<Self> { get }
}

extension TermContainerType {
	public static func out(container: Self) -> Expression<Self> {
		return container.out
	}
}


public protocol TermType: BooleanLiteralConvertible, CustomDebugStringConvertible, CustomStringConvertible, IntegerLiteralConvertible, StringLiteralConvertible, TermContainerType {
	init(_: () -> Expression<Self>)
}

extension TermType {
	public init(_ expression: Expression<Self>) {
		self.init { expression }
	}
}


public func == <Term: TermContainerType> (left: Term, right: Term) -> Bool {
	return left.out == right.out
}


// MARK: - Term: TermType over Expression<Term>

public func cata<T, Term: TermType>(f: Expression<T> -> T)(_ term: Term) -> T {
	return term |> (Term.out >>> (map <| cata(f)) >>> f)
}

public func para<T, Term: TermType>(f: Expression<(Term, T)> -> T)(_ term: Term) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (Term.out >>> (map <| fanout) >>> f)
}


public func ana<T, Term: TermType>(f: T -> Expression<T>)(_ seed: T) -> Term {
	return seed |> (Term.init <<< (map <| ana(f)) <<< f)
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
