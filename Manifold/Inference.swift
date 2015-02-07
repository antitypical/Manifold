//  Copyright (c) 2015 Rob Rix. All rights reserved.

public func typeOf(term: Expression, constraint: Constraint, environment: Environment) -> Either<Error, (Constraint, Type)> {
	switch term {
	case let .Value(value):
		return typeOf(value, constraint, environment)

	default:
		return .left("unimplemented")
	}
}

public func typeOf(value: Value, constraint: Constraint, environment: Environment) -> Either<Error, (Constraint, Type)> {
	switch value {
	case let .Variable(x):
		switch environment[x] {
		case let .Some(.Universal(alpha, d, tau)):
			switch tau.value {
			case let .Type(t):
				let beta = Variable()
				return .right(Constraint(exists: alpha, inConstraint: Constraint(Constraint(.Variable(beta), equals: t), and: d)), .Variable(beta))

			default:
				return .left("expected type assignment for variable")
			}

		default:
			return .left(Error(reason: "did not find a typing for \(value)"))
		}


	default:
		return .left("unimplemented")
	}
}


// MARK: - Imports

import Either
