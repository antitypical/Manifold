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


	/// Return a new Location by replacing the current value with a new one produced by `f`.
	public func modify(@noescape f: A -> A) -> Location {
		return Location(it: f(it), down: _down, up: _up, left: _left, right: _right)
	}


	public typealias Weave = A -> Unweave
	public typealias Unweave = (A -> Location?) -> Location?


	public static func explore(weave: Weave)(_ a : A) -> Location<A> {
		return Location(it: a, down: flip(weave)(explore(weave) >>> Optional.Some), up: const(nil), left: const(nil), right: const(nil))
	}


	// MARK: - Implementation details

	init?(_ weave: (A -> Location?) -> A -> Location?, _ up: A -> Location?, _ a: A) {
		func into(t1: A) -> Location? {
			return Location(it: t1, down: weave(into), up: up, left: const(nil), right: const(nil))
		}
		guard let location = into(a) else { return nil }
		self = location
	}

	init?(_ weave: (A -> Location?) -> A -> Location?, _ up: (A, A) -> Location?, _ t1: A, _ t2: A) {
		func into1(t1: A, _ t2: A) -> Location? {
			let update: ((A, A) -> Location?) -> A -> Location? = { fl in { t1 in fl(t1, t2) } }
			return Location(it: t1, down: weave(update(into1)), up: update(up), left: const(nil), right: update(into2))
		}
		func into2(t1: A, _ t2: A) -> Location? {
			let update: ((A, A) -> Location?) -> A -> Location? = { fl in { t2 in fl(t1, t2) } }
			return Location(it: t2, down: weave(update(into2)), up: update(up), left: update(into1), right: const(nil))
		}
		guard let location = into1(t1, t2) else { return nil }
		self = location
	}

	init?(_ weave: (A -> Location?) -> A -> Location?, _ up: (A, A, A) -> Location?, _ t1: A, _ t2: A, _ t3: A) {
		func into1(t1: A, _ t2: A, _ t3: A) -> Location? {
			let update: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t1 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(update(into1)), up: update(up), left: const(nil), right: update(into2))
		}
		func into2(t1: A, _ t2: A, _ t3: A) -> Location? {
			let update: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t2 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(update(into2)), up: update(up), left: update(into1), right: update(into3))
		}
		func into3(t1: A, _ t2: A, _ t3: A) -> Location? {
			let update: ((A, A, A) -> Location?) -> A -> Location? = { fl in { t3 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(update(into3)), up: update(up), left: update(into2), right: const(nil))
		}
		guard let location = into1(t1, t2, t3) else { return nil }
		self = location
	}
}


// Flipping of curried functions.
private func flip<A, B, C>(f: A -> B -> C)(_ b: B)(_ a: A) -> C {
	return f(a)(b)
}


import Prelude
