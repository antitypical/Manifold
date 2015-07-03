//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	init(Expression<Self>)
	var out: Expression<Self> { get }
}


// MARK: - Fix: FixpointType over Expression<Fix>

public func cata<T, Fix: FixpointType>(f: Expression<T> -> T)(_ term: Fix) -> T {
	return term |> (out >>> (map <| cata(f)) >>> f)
}

public func para<T, Fix: FixpointType>(f: Expression<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (out >>> (map <| fanout) >>> f)
}


public func ana<T, Fix: FixpointType>(f: T -> Expression<T>)(_ seed: T) -> Fix {
	return seed |> (Fix.init <<< (map <| ana(f)) <<< f)
}


public func apo<T>(f: T -> Expression<Either<Term, T>>)(_ seed: T) -> Term {
	return seed |> (Term.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


// MARK: - Implementation details

private func map<T, U>(f: T -> U)(_ c: Expression<T>) -> Expression<U> {
	return Expression.map(c)(f)
}

private func out<Fix: FixpointType>(v: Fix) -> Expression<Fix> {
	return v.out
}


import Either
import Prelude
