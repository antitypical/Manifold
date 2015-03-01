//  Copyright (c) 2015 Rob Rix. All rights reserved.

public protocol FixpointType {
	typealias Recur
	init(Recur)
	static func out(Self) -> Recur
}

public func cata<T, Fix: FixpointType where Fix.Recur == Constructor<Fix>>(f: Constructor<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (flip(uncurry(Constructor.map)) <| cata(f)) >>> f)
}


// MARK: - Imports

import Prelude
