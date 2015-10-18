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

public func cata<A, Term: TermContainerType>(f: Expression<A> -> A)(_ term: Term) -> A {
	return term |> (Term.out >>> (map <| cata(f)) >>> f)
}

public func para<A, Term: TermContainerType>(f: Expression<(Term, A)> -> A)(_ term: Term) -> A {
	let fanout = { ($0, para(f)($0)) }
	return term |> (Term.out >>> (map <| fanout) >>> f)
}


public func ana<A, Term: TermType>(f: A -> Expression<A>)(_ seed: A) -> Term {
	return seed |> (Term.init <<< (map <| ana(f)) <<< f)
}


public func apo<A>(f: A -> Expression<Either<Term, A>>)(_ seed: A) -> Term {
	return seed |> (Term.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


// MARK: - Implementation details

private func map<A, B>(f: A -> B)(_ c: Expression<A>) -> Expression<B> {
	return Expression.map(c)(f)
}


import Either
import Prelude
