//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Location<A> {
	public init(it: A, down: A -> Location?, up: A -> Location?, left: A -> Location?, right: A -> Location?) {
		self.it = it
		_left = left
		_right = right
		_up = up
		_down = down
	}

	public let it: A

	private let _down: A -> Location?
	public var down: Location? {
		return _down(it)
	}

	private let _up: A -> Location?
	public var up: Location? {
		return _up(it)
	}

	private let _left: A -> Location?
	public var left: Location? {
		return _left(it)
	}

	private let _right: A -> Location?
	public var right: Location? {
		return _right(it)
	}

	/// The root Location in the current exploration.
	public var root: Location {
		return up?.root ?? self
	}


	public func modify(@noescape f: A -> A) -> Location {
		return Location(it: f(it), down: _down, up: _up, left: _left, right: _right)
	}


	static func loc(weave: (A -> Location?) -> A -> Location?, _ fl0: A -> Location?) -> A -> Location? {
		func fl1(t1: A) -> Location? {
			return Location(it: t1, down: weave(fl1), up: fl0, left: const(nil), right: const(nil))
		}
		return fl1
	}

	static func loc(weave: (A -> Location?) -> A -> Location?, _ fl0: (A, A) -> Location?) -> (A, A) -> Location? {
		func fl1(t1: A, _ t2: A) -> Location? {
			let upd: ((A, A) -> Location?) -> A -> Location? = { fl in { t1 in fl(t1, t2) } }
			return Location(it: t1, down: weave(upd(fl1)), up: upd(fl0), left: const(nil), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A) -> Location? {
			let upd: ((A, A) -> Location?) -> A -> Location? = { fl in { t2 in fl(t1, t2) } }
			return Location(it: t2, down: weave(upd(fl2)), up: upd(fl0), left: upd(fl1), right: const(nil))
		}
		return fl1
	}

	static func loc(weave: (A -> Location?) -> A -> Location?, _ fl0: (A, A, A) -> Location?) -> (A, A, A) -> Location? {
		func fl1(t1: A, _ t2: A, _ t3: A) -> Location? {
			let upd: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t1 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl1)), up: upd(fl0), left: const(nil), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A, _ t3: A) -> Location? {
			let upd: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t2 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl3))
		}
		func fl3(t1: A, _ t2: A, _ t3: A) -> Location? {
			let upd: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t3 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl3)), up: upd(fl0), left: upd(fl2), right: const(nil))
		}
		return fl1
	}
}


import Prelude
