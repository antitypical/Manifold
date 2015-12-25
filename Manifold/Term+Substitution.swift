//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public var freeVariables: Set<Name> {
		switch self {
		case let .In(freeVariables, _):
			return freeVariables
		}
	}

	public func substitute(i: Int, _ expression: Term) -> Term {
		switch out {
		case let .Variable(.Local(j)) where i == j:
			return expression
		case let .Lambda(j, type, body):
			return .Lambda(j, type.substitute(i, expression), i == j
				? body
				: body.substitute(i, expression))
		case let .Application(a, b):
			return .Application(a.substitute(i, expression), b.substitute(i, expression))
		case let .Embedded(a, eq, type):
			return .Embedded(a, eq, type.substitute(i, expression))
		default:
			return self
		}
	}
}
