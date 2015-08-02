//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Weaver<A> {
	public typealias Weave = A -> Weaver
	public typealias Unweave = (A -> Location<A>?) -> Location<A>?

	public init() {
		self.init(unweave: const(nil))
	}

	public init(_ t1: A, _ weave: Weave, _ reconstruct: A -> A) {
		self.init { up in
			Location.loc(Weaver.call(weave), { t1 in up(reconstruct(t1)) })(t1)
		}
	}

	public init(_ t1: A, _ t2: A, _ weave: Weave, _ reconstruct: (A, A) -> A) {
		self.init { up in
			Location.loc(Weaver.call(weave), { t1, t2 in up(reconstruct(t1, t2)) })(t1, t2)
		}
	}

	public init(_ t1: A, _ t2: A, _ t3: A, _ weave: Weave, _ reconstruct:  (A, A, A) -> A) {
		self.init { up in
			Location.loc(Weaver.call(weave), { t1, t2, t3 in up(reconstruct(t1, t2, t3)) })(t1, t2, t3)
		}
	}

	private init(unweave: Unweave) {
		self.unweave = unweave
	}

	private let unweave: Unweave

	public static func call(weave: A -> Weaver)(_ up: A -> Location<A>?)(_ t: A) -> Location<A>? {
		return weave(t).unweave(up)
	}

	public static func explore(weave: A -> Weaver) -> A -> Location<A> {
		func into(a: A) -> Location<A> {
			return Location(it: a, down: call(weave)(into >>> Optional.Some), up: const(nil), left: const(nil), right: const(nil))
		}
		return into
	}
}


import Prelude
