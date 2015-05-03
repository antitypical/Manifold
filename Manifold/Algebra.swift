//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	typealias Recur

	init(_ : Recur)
	var out: Recur { get }
}

public func cata<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: Type<T> -> T)(_ term: Fix) -> T {
	return term |> (out >>> (flip(uncurry(Type.map)) <| cata(f)) >>> f)
}


public func para<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: Type<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout = { ($0, para(f)($0)) }
	return term |> (out >>> (flip(uncurry(Type.map)) <| fanout) >>> f)
}


public func ana<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: T -> Type<T>)(_ seed: T) -> Fix {
	return seed |> (`in` <<< (flip(uncurry(Type.map)) <| ana(f)) <<< f)
}


public func apo<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: T -> Type<Either<Fix, T>>)(_ seed: T) -> Fix {
	let fanin = flip(uncurry(Either<Fix, T>.either)) <| (id, { apo(f)($0) })
	return seed |> (`in` <<< (flip(uncurry(Type.map)) <| fanin) <<< f)
}


private func `in`<Fix: FixpointType>(v: Fix.Recur) -> Fix {
	return Fix(v)
}

private func out<Fix: FixpointType>(v: Fix) -> Fix.Recur {
	return v.out
}


import Either
import Prelude
