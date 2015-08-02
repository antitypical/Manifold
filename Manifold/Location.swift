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
	private let down: A -> Location
	private let up: A -> Location
	private let left: A -> Location
	private let right: A -> Location

	public static func loc(weave: (A -> Location) -> A -> Location, _ fl0: Location) -> Location {
		return fl0
	}

	public static func loc(weave: (A -> Location) -> A -> Location, _ fl0: A -> Location) -> A -> Location {
		let upd: (A -> Location) -> A -> Location = { fl in { t1 in fl(t1) } }
		func fl1(t1: A) -> Location {
			return Location(it: t1, down: weave(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl1))
		}
		return fl1
	}

	public static func loc(weave: (A -> Location) -> A -> Location, _ fl0: (A, A) -> Location) -> (A, A) -> Location {
		func fl1(t1: A, _ t2: A) -> Location {
			let upd: ((A, A) -> Location) -> A -> Location = { fl in { t1 in fl(t1, t2) } }
			return Location(it: t1, down: weave(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A) -> Location {
			let upd: ((A, A) -> Location) -> A -> Location = { fl in { t2 in fl(t1, t2) } }
			return Location(it: t2, down: weave(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		return fl1
	}

	public static func loc(weave: (A -> Location) -> A -> Location, _ fl0: (A, A, A) -> Location) -> (A, A, A) -> Location {
		func fl1(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t1 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t2 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl3))
		}
		func fl3(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t3 in fl(t1, t2, t3) } }
			return Location(it: t1, down: weave(upd(fl3)), up: upd(fl0), left: upd(fl2), right: upd(fl3))
		}
		return fl1
	}
}
