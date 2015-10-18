//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func elaborate(environment: [Name:Self], _ context: [Name:Self]) -> Either<Error, Elaborated<Self>> {
		return cata {
			switch $0 {
			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
