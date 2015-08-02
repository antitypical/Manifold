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

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: Location) -> Location {
		return fl0
	}

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: A -> Location) -> A -> Location {
		let upd: (A -> Location) -> A -> Location = { fl in { t1 in fl(t1) } }
		func fl1(t1: A) -> Location {
			return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl1))
		}
		return fl1
	}

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: (A, A) -> Location) -> (A, A) -> Location {
		func fl1(t1: A, _ t2: A) -> Location {
			let upd: ((A, A) -> Location) -> A -> Location = { fl in { t1 in fl(t1, t2) } }
			return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A) -> Location {
			let upd: ((A, A) -> Location) -> A -> Location = { fl in { t2 in fl(t1, t2) } }
			return Location(it: t2, down: wv(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		return fl1
	}

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: (A, A, A) -> Location) -> (A, A, A) -> Location {
		func fl1(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t1 in fl(t1, t2, t3) } }
			return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t2 in fl(t1, t2, t3) } }
			return Location(it: t1, down: wv(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl3))
		}
		func fl3(t1: A, _ t2: A, _ t3: A) -> Location {
			let upd: ((A, A, A) -> Location) -> A -> Location = { fl in { t3 in fl(t1, t2, t3) } }
			return Location(it: t1, down: wv(upd(fl3)), up: upd(fl0), left: upd(fl2), right: upd(fl3))
		}
		return fl1
	}
}


extension Expression where Recur: FixpointType {
	public static func weave(expression: Expression) -> Weaver<Expression> {
		switch expression {
		// MARK: Nullary
		case .Unit, .UnitType, .Type, .Variable, .BooleanType, .Boolean:
			return Weaver(expression, weave)

		// MARK: Unary
		case let .Projection(a, b):
			return Weaver(a.out, weave) { Expression.Projection(Recur($0), b) }

		case let .Axiom(any, type):
			return Weaver(type.out, weave) { Expression.Axiom(any, Recur($0)) }

		// MARK: Binary
		case let .Application(a, b):
			return Weaver(a.out, b.out, weave) { Expression.Application(Recur($0), Recur($1)) }

		case let .Lambda(i, a, b):
			return Weaver(a.out, b.out, weave) { Expression.Lambda(i, Recur($0), Recur($1)) }

		case let .Product(a, b):
			return Weaver(a.out, b.out, weave) { Expression.Product(Recur($0), Recur($1)) }

		case let .Annotation(a, b):
			return Weaver(a.out, b.out, weave) { Expression.Annotation(Recur($0), Recur($1)) }

		// MARK: Ternary
		case let .If(a, b, c):
			return Weaver(a.out, b.out, c.out, weave) { Expression.If(Recur($0), Recur($1), Recur($2)) }
		}
	}
}


import Prelude
