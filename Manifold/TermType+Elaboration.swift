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

			case let .Application(a, b):
				return a.flatMap { A in
					switch A.type.weakHeadNormalForm(environment).out {
					case let .Lambda(i, type, body):
						return b
							.flatMap { B in
								Self.equate(B.type, type, environment)
									? Either.right(B)
									: Either.Left("Type mismatch: expected '\(self)' to be of type '\(type)', but it was actually of type '\(B.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))")
							}
							.map { B in
								.Unroll(body.substitute(i, B.type), Expression.Application(A, B))
							}
					default:
						return Either.Left("Illegal application of \(a) : \(A) to \(b) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))")
					}
				}

			default:
				return .Left("unimplemented")
			}
		}
	}
}


import Either
