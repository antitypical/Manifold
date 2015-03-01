//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType {
	public init(_ out: Constructor<Term>) {
		self.out = out
	}

	public static func out(term: Term) -> Constructor<Term> {
		return term.out
	}

	public let out: Constructor<Term>
}


public protocol FixpointType {
	typealias F
	init(F)
	static func out(Self) -> F
}

public func cata<T, Fix: FixpointType where Fix.F == Constructor<Fix>>(f: Constructor<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (flip(uncurry(Constructor.map)) <| cata(f)) >>> f)
}


// MARK: - Imports

import Prelude
