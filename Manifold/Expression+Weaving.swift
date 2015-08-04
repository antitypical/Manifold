//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public func explore() -> Location<Expression> {
		func weave(expression: Expression) -> Location<Expression>.Unweave {
			switch expression {
			// MARK: Nullary
			case .Unit, .UnitType, .Type, .Variable, .BooleanType, .Boolean:
				return Location.nullary

			// MARK: Unary
			case let .Projection(a, b):
				return Location.unary(a.out, weave, { Expression.Projection(Recur($0), b) })

			case let .Axiom(any, type):
				return Location.unary(type.out, weave, { Expression.Axiom(any, Recur($0)) })

			// MARK: Binary
			case let .Application(a, b):
				return Location.binary(a.out, b.out, weave) { Expression.Application(Recur($0), Recur($1)) }

			case let .Lambda(i, a, b):
				return Location.binary(a.out, b.out, weave) { Expression.Lambda(i, Recur($0), Recur($1)) }

			case let .Product(a, b):
				return Location.binary(a.out, b.out, weave) { Expression.Product(Recur($0), Recur($1)) }

			case let .Annotation(a, b):
				return Location.binary(a.out, b.out, weave) { Expression.Annotation(Recur($0), Recur($1)) }

			// MARK: Ternary
			case let .If(a, b, c):
				return Location.ternary(a.out, b.out, c.out, weave) { Expression.If(Recur($0), Recur($1), Recur($2)) }
			}
		}
		return Location.explore(weave)(self)
	}
}
