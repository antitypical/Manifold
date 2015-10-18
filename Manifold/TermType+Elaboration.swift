//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func elaborate(environment: [Name:Self], _ context: [Name:Self]) -> Either<Error, Elaborated<Self>> {
		func assign(type: Self)(_ to: Self) -> Elaborated<Self> {
			return .Unroll(type, to.out.map(assign(type)))
		}
		return cata {
			switch $0 {
			case let .Type(n):
				return .Right(assign(.Type(n + 1))(self))
			case .UnitType, .BooleanType:
				return .Right(assign(.Type)(self))

			case .Unit:
				return .Right(assign(.UnitType)(self))
			case .Boolean:
				return .Right(assign(.BooleanType)(self))

			case let .Variable(name):
				return context[name].map {
					Either.Right(assign($0)(self))
				} ?? Either.Left("Unexpectedly free variable \(Self.describe(name)) in context: \(Self.toString(context: context)), environment: \(Self.toString(environment: environment))")

			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
