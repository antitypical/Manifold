//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Weaver<A> {
	public typealias Weave = A -> Weaver
	public typealias Unweave = (A -> Location<A>?) -> Location<A>?

	public init(_ k: A, _ weave: Weave) {
		self.init { fl0 in
			Location.loc(Weaver.call(weave), fl0(k))
		}
	}

	public init(_ t1: A, _ weave: Weave, _ k: A -> A) {
		self.init { fl0 in
			Location.loc(Weaver.call(weave), { t1 in fl0(k(t1)) })(t1)
		}
	}

	public init(_ t1: A, _ t2: A, _ weave: Weave, _ k: (A, A) -> A) {
		self.init { fl0 in
			Location.loc(Weaver.call(weave), { t1, t2 in fl0(k(t1, t2)) })(t1, t2)
		}
	}

	public init(_ t1: A, _ t2: A, _ t3: A, _ weave: Weave, _ k:  (A, A, A) -> A) {
		self.init { fl0 in
			Location.loc(Weaver.call(weave), { t1, t2, t3 in fl0(k(t1, t2, t3)) })(t1, t2, t3)
		}
	}

	private init(unweave: Unweave) {
		self.unweave = unweave
	}

	private let unweave: Unweave

	public static func call<T>(weave: T -> Weaver)(_ fl0: A -> Location<A>?)(_ t: T) -> Location<A>? {
		return weave(t).unweave(fl0)
	}

	public static func explore(weave: A -> Weaver) -> A -> Location<A> {
		func fr(a: A) -> Location<A> {
			let r = fr >>> Optional.Some
			return Location(it: a, down: call(weave)(r), up: r, left: r, right: r)
		}
		return fr
	}
}


import Prelude
