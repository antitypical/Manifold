//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func elaborate(environment: [Name:Self], _ context: [Name:Self]) -> Either<Error, Elaborated<Self>> {
		return cata {
			switch $0 {
			case let .Type(n):
				return .Right(.Unroll(.Type(n + 1), .Type(n)))

			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
