//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Elaborated {
	private func ensureLambda() throws -> (Int, Elaborated, Elaborated) {
		switch out {
		case let .Lambda(i, a, b):
			return (i, a, b)
		default:
			throw "Illegal application of \(term) : \(type)"
		}
	}
}

extension TermType {
	private func elaborate2(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
		switch (out, against?.weakHeadNormalForm(environment).out) {
		case let (.Type(n), .None):
			return .Unroll(.Type(n + 1), .Type(n))

		case let (.Variable(name), .None):
			guard let type = context[name] else {
				throw "Unexpectedly free variable \(name) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return .Unroll(type, .Variable(name))

		case let (.Application(a, b), .None):
			let a = try a.elaborate2(nil, environment, context)
			let (i, type, body) = try a.ensureLambda()
			let b = try b.elaborate2(type.term, environment, context)
			return .Unroll(body.term.substitute(i, b.term), .Application(a, b))

		case let (_, .Some(b)):
			let a = try elaborate2(nil, environment, context)
			guard Self.equate(a.type, Self(b), environment) else {
				throw "Type mismatch: expected '\(self)' to be of type '\(against)', but it was actually of type '\(a.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return a

		default:
			throw "unimplemented"
		}
	}

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
