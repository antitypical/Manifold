//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	typealias Recur
	static func In(Recur) -> Self
	static func out(Self) -> Recur
}

public func cata<T, Fix: FixpointType where Fix.Recur == Constructor<Fix>>(f: Constructor<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (flip(uncurry(Constructor.map)) <| cata(f)) >>> f)
}

public func cata<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: Type<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (flip(uncurry(Type.map)) <| cata(f)) >>> f)
}


public func para<T, Fix: FixpointType where Fix.Recur == Constructor<Fix>>(f: Constructor<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout: Fix -> (Fix, T) = { ($0, para(f)($0)) }
	return term |> (Fix.out >>> (flip(uncurry(Constructor.map)) <| fanout) >>> f)
}

public func para<T, Fix: FixpointType where Fix.Recur == Type<Fix>>(f: Type<(Fix, T)> -> T)(_ term: Fix) -> T {
	let fanout: Fix -> (Fix, T) = { ($0, para(f)($0)) }
	return term |> (Fix.out >>> (flip(uncurry(Type.map)) <| fanout) >>> f)
}


// MARK: - Imports

import Prelude
