//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Location<A> {
	public init(it: A, down: A -> Location, up: A -> Location, left: A -> Location, right: A -> Location) {
		self.it = it
		self.left = left
		self.right = right
		self.up = up
		self.down = down
	}

	public let it: A
	public let down: A -> Location
	public let up: A -> Location
	public let left: A -> Location
	public let right: A -> Location
}

public struct Weaver<A> {
	public typealias Weave = A -> Weaver
	public typealias Unweave = (A -> Location<A>) -> Location<A>

	public init(_ k: A, _ wv: Weave) {
		self.init { fl0 in
			loc0(Weaver.call(wv), fl0(k))
		}
	}

	public init(_ t1: A, _ k: A -> A, _ wv: Weave) {
		self.init { fl0 in
			loc1(Weaver.call(wv), { t1 in fl0(k(t1)) })(t1)
		}
	}

	public init(unweave: Unweave) {
		self.unweave = unweave
	}

	public let unweave: Unweave

	public static func call<T>(wv: T -> Weaver)(_ fl0: A -> Location<A>)(_ t: T) -> Location<A> {
		return wv(t).unweave(fl0)
	}
}


public func loc0<A>(wv: (A -> Location<A>) -> A -> Location<A>, _ fl0: Location<A>) -> Location<A> {
	return fl0
}

public func loc1<A>(wv: (A -> Location<A>) -> A -> Location<A>, _ fl0: A -> Location<A>) -> A -> Location<A> {
	let upd: (A -> Location<A>) -> A -> Location<A> = { fl in { t1 in fl(t1) } }
	func fl1(t1: A) -> Location<A> {
		return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl1))
	}
	return fl1
}

