//  Copyright © 2015 Rob Rix. All rights reserved.

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

	public func explore() -> Location<Expression> {
		return Weaver.explore(Expression.weave)(self)
	}
}
