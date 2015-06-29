//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	typealias Recur

	init(_ : Recur)
	var out: Recur { get }
}


// MARK: Fix: FixpointType over Inferable<Fix>

public func cata<T, Fix: FixpointType where Fix.Recur == Inferable<Fix>>(f: Inferable<T> -> T)(_ term: Fix) -> T {
	return term |> (out >>> (map <| cata(f)) >>> f)
}

public func para<T, Fix: FixpointType where Fix.Recur == Inferable<Fix>>(f: Inferable<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (out >>> (map <| fanout) >>> f)
}


public func ana<T, Fix: FixpointType where Fix.Recur == Inferable<Fix>>(f: T -> Inferable<T>)(_ seed: T) -> Fix {
	return seed |> (Fix.init <<< (map <| ana(f)) <<< f)
}


public func apo<T>(f: T -> Inferable<Either<Term, T>>)(_ seed: T) -> Term {
	return seed |> (Term.init <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


private func map<T, U>(f: T -> U)(_ c: Inferable<T>) -> Inferable<U> {
	return Inferable.map(c)(f)
}

private func out<Fix: FixpointType>(v: Fix) -> Fix.Recur {
	return v.out
}


import Either
import Prelude
