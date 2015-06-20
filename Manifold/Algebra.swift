//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	typealias Recur

	init(_ : Recur)
	var out: Recur { get }
}


// MARK: Fix: FixpointType over Checkable<Fix>

public func cata<T, Fix: FixpointType where Fix.Recur == Checkable<Fix>>(f: Checkable<T> -> T)(_ term: Fix) -> T {
	return term |> (out >>> (map <| cata(f)) >>> f)
}

public func zeppo<T, Fix: FixpointType where Fix.Recur == Checkable<Fix>>(f: Checkable<([Fix], T)> -> T)(_ parents: [Fix])(_ term: Fix) -> T {
	let fanout = { (parents, zeppo(f)(parents + [$0])($0)) }
	return term |> (out >>> (map <| fanout) >>> f)
}

public func para<T, Fix: FixpointType where Fix.Recur == Checkable<Fix>>(f: Checkable<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (out >>> (map <| fanout) >>> f)
}


public func ana<T, Fix: FixpointType where Fix.Recur == Checkable<Fix>>(f: T -> Checkable<T>)(_ seed: T) -> Fix {
	return seed |> (`in` <<< (map <| ana(f)) <<< f)
}


public func apo<T>(f: T -> Checkable<Either<Term, T>>)(_ seed: T) -> Term {
	return seed |> (`in` <<< (map { $0.either(ifLeft: id, ifRight: apo(f)) }) <<< f)
}


private func map<T, U>(f: T -> U)(_ c: Checkable<T>) -> Checkable<U> {
	return Checkable.map(c)(f)
}

private func `in`<Fix: FixpointType>(v: Fix.Recur) -> Fix {
	return Fix(v)
}

private func out<Fix: FixpointType>(v: Fix) -> Fix.Recur {
	return v.out
}


import Either
import Prelude
