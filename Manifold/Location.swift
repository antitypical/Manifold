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

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: A -> A -> Location) -> A -> A -> Location {
		func fl1(t1: A)(_ t2: A) -> Location {
			let upd: (A -> A -> Location) -> A -> Location = { fl in { t1 in fl(t1)(t2) } }
			return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A)(_ t2: A) -> Location {
			let upd: (A -> A -> Location) -> A -> Location = { fl in { t2 in fl(t1)(t2) } }
			return Location(it: t2, down: wv(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		return fl1
	}

	public static func loc(wv: (A -> Location) -> A -> Location, _ fl0: A -> A -> A -> Location) -> A -> A -> A -> Location {
		func fl1(t1: A)(_ t2: A)(_ t3: A) -> Location {
			let upd: (A -> A -> A -> Location) -> A -> Location = { fl in { t1 in fl(t1)(t2)(t3) } }
			return Location(it: t1, down: wv(upd(fl1)), up: upd(fl0), left: upd(fl1), right: upd(fl2))
		}
		func fl2(t1: A)(_ t2: A)(_ t3: A) -> Location {
			let upd: (A -> A -> A -> Location) -> A -> Location = { fl in { t2 in fl(t1)(t2)(t3) } }
			return Location(it: t1, down: wv(upd(fl2)), up: upd(fl0), left: upd(fl1), right: upd(fl3))
		}
		func fl3(t1: A)(_ t2: A)(_ t3: A) -> Location {
			let upd: (A -> A -> A -> Location) -> A -> Location = { fl in { t3 in fl(t1)(t2)(t3) } }
			return Location(it: t1, down: wv(upd(fl3)), up: upd(fl0), left: upd(fl2), right: upd(fl3))
		}
		return fl1
	}
}

public struct Weaver<A> {
	public typealias Weave = A -> Weaver
	public typealias Unweave = (A -> Location<A>) -> Location<A>

	public init(_ k: A, _ wv: Weave) {
		self.init { fl0 in
			Location.loc(Weaver.call(wv), fl0(k))
		}
	}

	public init(_ t1: A, _ k: A -> A, _ wv: Weave) {
		self.init { fl0 in
			Location.loc(Weaver.call(wv), { t1 in fl0(k(t1)) })(t1)
		}
	}

	public init(_ t1: A, _ t2: A, _ k: A -> A -> A, _ wv: Weave) {
		self.init { fl0 in
			Location.loc(Weaver.call(wv), { t1 in { t2 in fl0(k(t1)(t2)) } })(t1)(t2)
		}
	}

	public init(_ t1: A, _ t2: A, _ t3: A, _ k:  (A, A, A) -> A, _ wv: Weave) {
		self.init { fl0 in
			Location.loc(Weaver.call(wv), { t1 in { t2 in { t3 in fl0(k(t1, t2, t3)) } } })(t1)(t2)(t3)
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

extension Expression where Recur: FixpointType {
	public static func weave(expression: Expression) -> Weaver<Expression> {
		switch expression {
		// MARK: Nullary
		case .Unit, .UnitType, .Type, .Variable, .BooleanType, .Boolean:
			return Weaver(expression, weave)

		// MARK: Unary
		case let .Projection(a, b):
			return Weaver(a.out, { Expression.Projection(Recur($0), b) }, weave)

		case let .Axiom(any, type):
			return Weaver(type.out, { Expression.Axiom(any, Recur($0)) }, weave)

		// MARK: Binary
		case let .Application(a, b):
			return Weaver(a.out, b.out, curry { Expression.Application(Recur($0), Recur($1)) }, weave)

		case let .Lambda(i, a, b):
			return Weaver(a.out, b.out, curry { Expression.Lambda(i, Recur($0), Recur($1)) }, weave)

		case let .Product(a, b):
			return Weaver(a.out, b.out, curry { Expression.Product(Recur($0), Recur($1)) }, weave)

		case let .Annotation(a, b):
			return Weaver(a.out, b.out, curry { Expression.Annotation(Recur($0), Recur($1)) }, weave)

		// MARK: Ternary
		case let .If(a, b, c):
			return Weaver(a.out, b.out, c.out, { Expression.If(Recur($0), Recur($1), Recur($2)) }, weave)
		}
	}
}


import Prelude
