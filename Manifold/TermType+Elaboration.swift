//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func elaborate(environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		func assign(type: Self)(_ to: Self) -> Elaborated<Self> {
			return .Unroll(type, to.out.map(assign(type)))
		}
		return cata {
			switch $0 {
			case let .Type(n):
				return .Right(assign(.Type(n + 1))(self))

			case let .Variable(name):
				return context[name]
					.map { Either.Right(assign($0)(self)) }
					?? Either.Left("Unexpectedly free variable \(name) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))")

			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
