//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func elaborate(environment: [Name:Self], _ context: [Name:Self]) -> Either<Error, Elaborated<Self>> {
		func assign(type: Self)(_ to: Self) -> Elaborated<Self> {
			return .Unroll(type, to.out.map(assign(type)))
		}
		return cata {
			switch $0 {
			case let .Type(n):
				return .Right(.Unroll(.Type(n + 1), .Type(n)))

			case .UnitType, .BooleanType:
				return .Right(assign(.Type)(self))

			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
