//  Copyright (c) 2015 Rob Rix. All rights reserved.

extension Constructor: Relatable {
	public typealias To = T

	public func toFunctor<U>() -> Functor<Constructor, Constructor<U>> {
		return Functor(self, Constructor.map)
	}
}

public struct Term: FixpointType {
	public init(_ out: Constructor<Term>) {
		self.out = out
	}

	public static func out(term: Term) -> Constructor<Term> {
		return term.out
	}

	public let out: Constructor<Term>
}

public struct Functor<F: Relatable, G: Relatable>: Relatable {
	public init(_ out: F, _ map: F -> (F.To -> G.To) -> G) {
		self.out = out
		self.map = map
	}

	public func map(transform: F.To -> G.To) -> G {
		return map(out)(transform)
	}

	private let out: F
	private let map: F -> (F.To -> G.To) -> G


	// MARK: Relatable

	public typealias To = F.To
}

public protocol Relatable {
	typealias To
}

public protocol FixpointType {
	typealias F
	init(F)
	static func out(Self) -> F
}

public func cata<T, Fix: FixpointType, F: Relatable, G: Relatable where Fix.F == Functor<F, G>, F.To == Fix, G.To == T>(f: G -> T)(_ term: Fix) -> T {
	return f(Fix.out(term).map(cata(f)))
}

public func cata<T, Fix: FixpointType where Fix.F == Constructor<Fix>>(f: Constructor<T> -> T)(_ term: Fix) -> T {
	return term |> (Fix.out >>> (flip(uncurry(Constructor.map)) <| cata(f)) >>> f)
}


// MARK: - Imports

import Prelude
